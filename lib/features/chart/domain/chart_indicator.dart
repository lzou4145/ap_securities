/// Built-in overlays computed from MQTT bars (chart tab).
enum ChartIndicator {
  ma20,
  ema12,
  rsi14,
}

extension ChartIndicatorX on ChartIndicator {
  String get jsValue => switch (this) {
        ChartIndicator.ma20 => 'ma20',
        ChartIndicator.ema12 => 'ema12',
        ChartIndicator.rsi14 => 'rsi14',
      };
}
