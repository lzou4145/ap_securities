import 'package:ap_securities/core/mqtt/market_tick_mqtt_client.dart';
import 'package:ap_securities/core/mqtt/mqtt_tick_parser.dart';
import 'package:ap_securities/features/chart/domain/chart_candle.dart';
import 'package:ap_securities/features/chart/domain/chart_candle_tick_merge.dart';
import 'package:ap_securities/features/chart/domain/chart_resolution.dart';
import 'package:ap_securities/features/chart/domain/chart_state.dart';
import 'package:ap_securities/features/chart/domain/mqtt_history_result.dart';

/// Shared MQTT history / tick handling for chart tab and trade order charts.
abstract final class MqttCandleChartOps {
  static ChartState applyHistory(ChartState state, MqttHistoryResult result) {
    if (state.symbol != result.symbol) return state;

    final merged = ChartCandleTickMerge.mergeBars(state.bars, result.bars);
    final earliest = merged.isEmpty ? null : merged.first.timeMs;

    return state.copyWith(
      bars: merged,
      loading: false,
      earliestLoadedMs: earliest,
    );
  }

  static ChartState applyTick(ChartState state, MqttTickQuote tick) {
    if (state.symbol != tick.symbol) return state;

    if (state.bars.isEmpty) {
      final price = ChartCandleTickMerge.tickPrice(tick);
      final startMs =
          ChartCandleTickMerge.barStartMs(tick.timestampMs, state.resolution);
      return state.copyWith(
        bars: [
          ChartCandle(
            timeMs: startMs,
            open: price,
            high: price,
            low: price,
            close: price,
            volume: 0,
            bid: tick.bid,
            ask: tick.ask,
          ),
        ],
        loading: false,
      );
    }

    final next = ChartCandleTickMerge.applyTick(
      bars: state.bars,
      tick: tick,
      resolution: state.resolution,
    );
    return state.copyWith(bars: next);
  }

  static void requestHistoryRange({
    required MarketTickMqttClient mqtt,
    required String symbol,
    required ChartResolution resolution,
    required int fromMs,
    required int toMs,
  }) {
    if (!mqtt.isConnected) return;
    mqtt.requestHistory(
      symbol: symbol,
      resolution: resolution.mqttValue,
      fromMs: fromMs,
      toMs: toMs,
    );
  }

  static void requestInitialHistory({
    required MarketTickMqttClient mqtt,
    required ChartState state,
  }) {
    final symbol = state.symbol;
    if (symbol == null || symbol.isEmpty) return;

    final toMs = DateTime.now().millisecondsSinceEpoch;
    final fromMs =
        toMs - state.resolution.barDurationMs() * ChartResolution.initialBarCount;

    requestHistoryRange(
      mqtt: mqtt,
      symbol: symbol,
      resolution: state.resolution,
      fromMs: fromMs,
      toMs: toMs,
    );
  }
}
