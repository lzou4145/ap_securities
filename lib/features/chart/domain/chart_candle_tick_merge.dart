import 'package:ap_securities/core/mqtt/mqtt_tick_parser.dart';
import 'package:ap_securities/features/chart/domain/chart_candle.dart';
import 'package:ap_securities/features/chart/domain/chart_resolution.dart';

/// Merges MQTT ticks into OHLC bars for a given [resolution].
abstract final class ChartCandleTickMerge {
  static double tickPrice(MqttTickQuote tick) => (tick.bid + tick.ask) / 2;

  static int barStartMs(int timestampMs, ChartResolution resolution) {
    final bucket = resolution.barDurationMs();
    return (timestampMs ~/ bucket) * bucket;
  }

  static List<ChartCandle> applyTick({
    required List<ChartCandle> bars,
    required MqttTickQuote tick,
    required ChartResolution resolution,
  }) {
    final price = tickPrice(tick);
    final startMs = barStartMs(tick.timestampMs, resolution);
    final map = <int, ChartCandle>{
      for (final bar in bars) bar.timeMs: bar,
    };

    final existing = map[startMs];
    if (existing != null) {
      map[startMs] = ChartCandle(
        timeMs: startMs,
        open: existing.open,
        high: price > existing.high ? price : existing.high,
        low: price < existing.low ? price : existing.low,
        close: price,
        volume: existing.volume,
        bid: tick.bid,
        ask: tick.ask,
      );
    } else {
      map[startMs] = ChartCandle(
        timeMs: startMs,
        open: price,
        high: price,
        low: price,
        close: price,
        volume: 0,
        bid: tick.bid,
        ask: tick.ask,
      );
    }

    return map.values.toList()..sort((a, b) => a.timeMs.compareTo(b.timeMs));
  }

  static List<ChartCandle> mergeBars(
    List<ChartCandle> existing,
    List<ChartCandle> incoming,
  ) {
    final map = <int, ChartCandle>{
      for (final bar in existing) bar.timeMs: bar,
      for (final bar in incoming) bar.timeMs: bar,
    };
    return map.values.toList()..sort((a, b) => a.timeMs.compareTo(b.timeMs));
  }
}
