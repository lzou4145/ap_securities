import 'package:ap_securities/core/api/app_api.dart';
import 'package:ap_securities/features/market/data/market_variety_mapper.dart';
import 'package:ap_securities/features/market/domain/market_quote.dart';
import 'package:ap_securities/features/market/domain/trading_symbol_candidate.dart';

/// Market watchlist and symbol catalog via APP-api `/api/market/*`.
class MarketRepository {
  MarketRepository(this._api);

  final AppApi _api;

  Future<List<MarketQuote>> fetchWatchlist() async {
    final groups = await _api.market.getAccountVarietyList();
    return MarketVarietyMapper.watchlistFromGroupMap(groups);
  }

  Future<List<TradingSymbolCandidate>> fetchCatalog({
    String? type,
    String? code,
  }) async {
    final list = await _api.market.getVarietyList(type, code);
    return list.map(MarketVarietyMapper.candidateFromVariety).toList();
  }

  Future<List<TradingSymbolCandidate>> fetchVarietyFuzzy(String name) async {
    final list = await _api.market.getVarietyFuzzy(name);
    return list.map(MarketVarietyMapper.candidateFromVariety).toList();
  }

  Future<void> addToWatchlist(int varietyId) async {
    await _api.market.addAccountVariety(varietyId.toString());
  }

  Future<void> removeFromWatchlist(Iterable<String> varietyIds) async {
    final joined = varietyIds.where((e) => e.isNotEmpty).join(',');
    if (joined.isEmpty) return;
    await _api.market.delAccountVariety(joined);
  }

  Future<void> saveWatchlistOrder(List<MarketQuote> quotes) async {
    if (quotes.isEmpty) return;
    await _api.market.setAccountVarietySort(
      MarketVarietyMapper.buildSortJson(quotes),
    );
  }
}
