import 'package:ap_securities/features/chart/domain/chart_candle.dart';

/// Parsed MQTT history bars response on `push/history/{deviceId}`.
class MqttHistoryBars {
  const MqttHistoryBars({required this.bars});

  final List<ChartCandle> bars;
}

abstract final class MqttHistoryParser {
  static const supportedResolutions = {
    'minute',
    'minute5',
    'minute15',
    'minute30',
    'hour',
    'hour2',
    'hour4',
    'hour6',
    'hour8',
    'day',
    'week',
    'month',
  };

  /// Request payload: `SYMBOL:resolution:fromMs:toMs`.
  static String buildRequest({
    required String symbol,
    required String resolution,
    required int fromMs,
    required int toMs,
  }) {
    return '$symbol:$resolution:$fromMs:$toMs';
  }

  /// Parses `time:open:high:low:close:volume:extra;...` into candles.
  static MqttHistoryBars? parsePushPayload(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    final bars = <ChartCandle>[];
    for (final segment in text.split(';')) {
      final candle = _parseBar(segment);
      if (candle != null) {
        bars.add(candle);
      }
    }
    if (bars.isEmpty) return null;
    bars.sort((a, b) => a.timeMs.compareTo(b.timeMs));
    return MqttHistoryBars(bars: bars);
  }

  static ChartCandle? _parseBar(String segment) {
    final parts = segment.trim().split(':');
    if (parts.length < 6) return null;

    final timeMs = int.tryParse(parts[0]);
    final open = double.tryParse(parts[1]);
    final high = double.tryParse(parts[2]);
    final low = double.tryParse(parts[3]);
    final close = double.tryParse(parts[4]);
    final volume = double.tryParse(parts[5]);
    if (timeMs == null ||
        open == null ||
        high == null ||
        low == null ||
        close == null ||
        volume == null) {
      return null;
    }

    return ChartCandle(
      timeMs: timeMs,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
      bid: close,
      ask: close,
    );
  }
}
