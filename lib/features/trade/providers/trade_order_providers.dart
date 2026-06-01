import 'package:ap_securities/features/market/providers/market_watchlist_notifier.dart';
import 'package:ap_securities/features/trade/data/trade_symbol_mapper.dart';
import 'package:ap_securities/features/trade/domain/order_execution_type.dart';
import 'package:ap_securities/features/trade/domain/trade_symbol_quote.dart';
import 'package:ap_securities/features/trade/providers/trade_mqtt_response_providers.dart';
import 'package:ap_securities/features/trade/providers/trade_order_modify_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Order-screen quote derived from [marketWatchlistProvider] (same data as market tab).
final tradeOrderQuoteProvider = Provider.autoDispose
    .family<AsyncValue<TradeSymbolQuote>, String>((ref, symbol) {
  if (symbol.isEmpty) {
    return const AsyncLoading();
  }

  final watchlistAsync = ref.watch(marketWatchlistProvider);

  return watchlistAsync.when(
    data: (quotes) {
      final marketQuote =
          quotes.where((q) => q.symbol == symbol).firstOrNull;
      if (marketQuote != null) {
        return AsyncData(TradeSymbolMapper.fromMarketQuote(marketQuote));
      }
      return AsyncData(TradeSymbolMapper.fallback(symbol));
    },
    loading: () => const AsyncLoading(),
    error: AsyncError.new,
  );
});

/// Form state scoped to the trade order screen; auto-disposes when the page unmounts.
final orderExecutionTypeProvider =
    StateProvider.autoDispose<OrderExecutionType>(
  (ref) => OrderExecutionType.instant,
);

final orderLotSizeProvider = StateProvider.autoDispose<double?>((ref) => null);

final orderLimitPriceProvider =
    StateProvider.autoDispose<double?>((ref) => null);

/// Max slippage in points — only for instant execution.
final orderDeviationPointsProvider =
    StateProvider.autoDispose<int?>((ref) => null);

final orderStopLossPriceProvider =
    StateProvider.autoDispose<double?>((ref) => null);

final orderTakeProfitPriceProvider =
    StateProvider.autoDispose<double?>((ref) => null);

/// Pending order expiry (limit/stop); must be after [DateTime.now] when set.
final orderExpiryAtProvider =
    StateProvider.autoDispose<DateTime?>((ref) => null);

/// Clears order form providers when leaving the order page.
void resetTradeOrderForm(
  ProviderContainer container, {
  bool clearModifyContext = true,
}) {
  container.invalidate(orderLotSizeProvider);
  container.invalidate(orderLimitPriceProvider);
  container.invalidate(orderDeviationPointsProvider);
  container.invalidate(orderStopLossPriceProvider);
  container.invalidate(orderTakeProfitPriceProvider);
  container.invalidate(orderExpiryAtProvider);
  container.invalidate(orderExecutionTypeProvider);
  container.read(tradePendingOrderPendingProvider.notifier).state = null;
  container.read(tradeInstantOrderPendingProvider.notifier).state = null;
  if (clearModifyContext) {
    container.read(tradeOrderModifyContextProvider.notifier).state = null;
  }
  container.read(tradeModifyProfitLossPendingProvider.notifier).state = null;
  container.read(tradeCloseOrderPendingProvider.notifier).state = null;
}

/// Clears price/lot inputs but keeps the selected execution type.
void clearTradeOrderInputs(WidgetRef ref) {
  ref.invalidate(orderLotSizeProvider);
  ref.invalidate(orderLimitPriceProvider);
  ref.invalidate(orderDeviationPointsProvider);
  ref.invalidate(orderStopLossPriceProvider);
  ref.invalidate(orderTakeProfitPriceProvider);
  ref.invalidate(orderExpiryAtProvider);
  ref.read(tradePendingOrderPendingProvider.notifier).state = null;
}
