import 'package:ap_securities/core/mqtt/mqtt_tick_parser.dart';
import 'package:ap_securities/features/chart/domain/chart_intraday_tick_merge.dart';
import 'package:ap_securities/features/chart/domain/chart_state.dart';
import 'package:ap_securities/features/chart/domain/mqtt_history_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extra MQTT symbol while the trade order screen is open (may not be on watchlist).
final tradeOrderMqttExtraSymbolProvider = StateProvider<String?>((ref) => null);

final tradeOrderChartProvider = NotifierProvider.autoDispose
    .family<TradeOrderChartNotifier, ChartState, String>(
  TradeOrderChartNotifier.new,
);

/// Intraday bid/ask chart — live ticks only, no MQTT history.
class TradeOrderChartNotifier extends AutoDisposeFamilyNotifier<ChartState, String> {
  @override
  ChartState build(String arg) {
    return ChartState(symbol: arg);
  }

  void ensureLoaded() {
    state = state.copyWith(loading: false);
  }

  void markChartReady() {
    state = state.copyWith(chartReady: true);
  }

  void resetChartReady() {
    state = state.copyWith(chartReady: false);
  }

  void clearPoints() {
    state = state.copyWith(clearBars: true, loading: false);
  }

  /// Ignored — trade order chart does not load history.
  void applyHistoryForSymbol(MqttHistoryResult result) {}

  void applyTick(MqttTickQuote tick) {
    if (state.symbol != tick.symbol) return;

    final next = ChartIntradayTickMerge.applyTick(
      points: state.bars,
      tick: tick,
    );
    state = state.copyWith(bars: next, loading: false);
  }

  /// Ignored — no history pagination on trade order chart.
  void loadMoreHistory({required int fromMs, required int toMs}) {}
}
