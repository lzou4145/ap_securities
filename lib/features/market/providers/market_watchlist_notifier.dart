import 'package:ap_securities/core/mqtt/mqtt_day_parser.dart';
import 'package:ap_securities/core/mqtt/mqtt_tick_parser.dart';
import 'package:ap_securities/features/market/data/market_repository.dart';
import 'package:ap_securities/features/market/domain/market_price_format.dart';
import 'package:ap_securities/features/market/domain/market_quote.dart';
import 'package:ap_securities/features/market/domain/market_spread.dart';
import 'package:ap_securities/features/market/domain/trading_symbol_candidate.dart';
import 'package:ap_securities/features/market/providers/market_providers.dart';
import 'package:ap_securities/providers/active_account_scope.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final marketWatchlistProvider =
    AsyncNotifierProvider<MarketWatchlistNotifier, List<MarketQuote>>(
  MarketWatchlistNotifier.new,
);

class MarketWatchlistNotifier extends AsyncNotifier<List<MarketQuote>> {
  MarketRepository get _repo => ref.read(marketRepositoryProvider);

  @override
  Future<List<MarketQuote>> build() {
    ref.watch(activeAccountScopeProvider);
    return _repo.fetchWatchlist();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _repo.fetchWatchlist());
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.value;
    if (current == null) return;

    final items = [...current];
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    final item = items.removeAt(oldIndex);
    items.insert(target, item);

    state = AsyncData(items);
    try {
      await _repo.saveWatchlistOrder(items);
    } on Object {
      state = AsyncData(await _repo.fetchWatchlist());
      rethrow;
    }
  }

  Future<void> removeByIds(Set<String> ids) async {
    if (ids.isEmpty) return;
    final previous = state.value ?? [];
    final next = previous.where((q) => !ids.contains(q.id)).toList();
    state = AsyncData(next);
    try {
      await _repo.removeFromWatchlist(ids);
    } on Object {
      state = AsyncData(await _repo.fetchWatchlist());
      rethrow;
    }
  }

  Future<void> addVariety(int varietyId) async {
    await _repo.addToWatchlist(varietyId);
    await refresh();
  }

  /// Applies `push/day` batch (`SYM:ts:high:low;…`) — updates session low/high only.
  void applyDayHighLowBatch(Iterable<MqttDayQuote> dayQuotes) {
    final current = state.value;
    if (current == null) return;

    final bySymbol = {for (final q in dayQuotes) q.symbol: q};
    if (bySymbol.isEmpty) return;

    var changed = false;
    final next = current.map((quote) {
      final day = bySymbol[quote.symbol];
      if (day == null) return quote;
      final updated = _quoteWithDayHighLow(quote, day);
      if (updated != quote) changed = true;
      return updated;
    }).toList();

    if (changed) state = AsyncData(next);
  }

  /// Applies a real-time MQTT tick to the matching watchlist row.
  void applyTick(MqttTickQuote tick) {
    final current = state.value;
    if (current == null) return;

    var changed = false;
    final next = current.map((quote) {
      if (quote.symbol != tick.symbol) return quote;
      changed = true;
      return _quoteWithTick(quote, tick);
    }).toList();

    if (changed) state = AsyncData(next);
  }

  MarketQuote _quoteWithDayHighLow(MarketQuote quote, MqttDayQuote day) {
    final places = quote.decimalPlace;
    return quote.copyWith(
      bidLow: roundMarketPrice(day.low, places),
      askHigh: roundMarketPrice(day.high, places),
    );
  }

  MarketQuote _quoteWithTick(MarketQuote quote, MqttTickQuote tick) {
    final time = DateTime.fromMillisecondsSinceEpoch(tick.timestampMs);
    final updatedAt = '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
    final spread = marketSpreadFromPrices(
      bid: tick.bid,
      ask: tick.ask,
      decimalPlace: quote.decimalPlace,
    );
    final trend = tick.bid >= quote.bid ? QuoteTrend.up : QuoteTrend.down;

    final places = quote.decimalPlace;
    final bid = roundMarketPrice(tick.bid, places);
    final ask = roundMarketPrice(tick.ask, places);
    return quote.copyWith(
      bid: bid,
      ask: ask,
      bidDisplay: formatMarketPrice(bid, decimalPlace: places),
      askDisplay: formatMarketPrice(ask, decimalPlace: places),
      updatedAt: updatedAt,
      spread: spread,
      trend: trend,
    );
  }
}

final addSymbolSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

/// Fuzzy search results; excludes symbols already on the watchlist.
final filteredTradingSymbolFuzzySearchProvider =
    Provider.autoDispose<AsyncValue<List<TradingSymbolCandidate>>>((ref) {
  final query = ref.watch(addSymbolSearchQueryProvider).trim();
  if (query.isEmpty) {
    return const AsyncData([]);
  }

  final searchAsync = ref.watch(tradingSymbolFuzzySearchProvider(query));
  final watchlistAsync = ref.watch(marketWatchlistProvider);

  return searchAsync.when(
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
    data: (catalog) {
      return watchlistAsync.when(
        loading: () => const AsyncLoading(),
        error: (e, st) => AsyncError(e, st),
        data: (watchlist) {
          final onWatch = watchlist.map((e) => e.id).toSet();
          final filtered = catalog
              .where((c) => !onWatch.contains(c.varietyId.toString()))
              .toList();
          return AsyncData(filtered);
        },
      );
    },
  );
});

/// Catalog rows for a category; excludes symbols already on the watchlist.
final filteredTradingSymbolCatalogByTypeProvider = Provider.autoDispose
    .family<AsyncValue<List<TradingSymbolCandidate>>, String>((ref, type) {
  final catalogAsync = ref.watch(tradingSymbolCatalogByTypeProvider(type));
  final watchlistAsync = ref.watch(marketWatchlistProvider);

  return catalogAsync.when(
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
    data: (catalog) {
      return watchlistAsync.when(
        loading: () => const AsyncLoading(),
        error: (e, st) => AsyncError(e, st),
        data: (watchlist) {
          final onWatch = watchlist.map((e) => e.id).toSet();
          final filtered = catalog
              .where((c) => !onWatch.contains(c.varietyId.toString()))
              .toList();
          return AsyncData(filtered);
        },
      );
    },
  );
});
