/// One OHLCV bar for the chart (MQTT history or live aggregation).
class ChartCandle {
  const ChartCandle({
    required this.timeMs,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.bid,
    required this.ask,
  });

  final int timeMs;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  /// Last bid in the bar (history uses [close] when bid/ask are unavailable).
  final double bid;

  /// Last ask in the bar (history uses [close] when bid/ask are unavailable).
  final double ask;

  /// Lightweight Charts UTCTimestamp (seconds).
  int get timeSec => timeMs ~/ 1000;

  Map<String, Object> toChartJson() => {
        'time': timeSec,
        'open': open,
        'high': high,
        'low': low,
        'close': close,
        'volume': volume,
        'bid': bid,
        'ask': ask,
      };
}
