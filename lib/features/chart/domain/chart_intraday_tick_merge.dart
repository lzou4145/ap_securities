import 'package:ap_securities/core/mqtt/mqtt_tick_parser.dart';
import 'package:ap_securities/features/chart/domain/chart_candle.dart';

/// Builds intraday (分时) bid/ask points from live ticks — one point per second.
abstract final class ChartIntradayTickMerge {
  static List<ChartCandle> applyTick({
    required List<ChartCandle> points,
    required MqttTickQuote tick,
  }) {
    final timeMs = (tick.timestampMs ~/ 1000) * 1000;
    final map = <int, ChartCandle>{
      for (final point in points) point.timeMs: point,
    };

    map[timeMs] = ChartCandle(
      timeMs: timeMs,
      open: tick.bid,
      high: tick.ask,
      low: tick.bid,
      close: (tick.bid + tick.ask) / 2,
      volume: 0,
      bid: tick.bid,
      ask: tick.ask,
    );

    return map.values.toList()..sort((a, b) => a.timeMs.compareTo(b.timeMs));
  }
}
