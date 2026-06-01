import 'package:ap_securities/features/chart/providers/chart_providers.dart';
import 'package:ap_securities/features/chart/providers/trade_order_chart_providers.dart';
import 'package:ap_securities/features/market/providers/market_watchlist_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// All symbols that should receive MQTT tick subscriptions.
final mqttChartSymbolsProvider = Provider<Set<String>>((ref) {
  final symbols = <String>{};

  final watchlist = ref.watch(marketWatchlistProvider).valueOrNull;
  if (watchlist != null) {
    symbols.addAll(watchlist.map((q) => q.symbol));
  }

  final chartSymbol = ref.watch(
    chartControllerProvider.select((s) => s.symbol),
  );
  if (chartSymbol != null && chartSymbol.isNotEmpty) {
    symbols.add(chartSymbol);
  }

  final orderSymbol = ref.watch(tradeOrderMqttExtraSymbolProvider);
  if (orderSymbol != null && orderSymbol.isNotEmpty) {
    symbols.add(orderSymbol);
  }

  return symbols;
});
