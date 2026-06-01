/// Chart interval — maps to MQTT history resolution strings.
enum ChartResolution {
  minute1('1', 'minute', Duration(minutes: 1)),
  minute5('5', 'minute5', Duration(minutes: 5)),
  minute15('15', 'minute15', Duration(minutes: 15)),
  minute30('30', 'minute30', Duration(minutes: 30)),
  hour1('60', 'hour', Duration(hours: 1)),
  hour2('120', 'hour2', Duration(hours: 2)),
  hour4('240', 'hour4', Duration(hours: 4)),
  hour6('360', 'hour6', Duration(hours: 6)),
  hour8('480', 'hour8', Duration(hours: 8)),
  day1('D', 'day', Duration(days: 1)),
  week1('W', 'week', Duration(days: 7)),
  month1('M', 'month', Duration(days: 30));

  const ChartResolution(this.label, this.mqttValue, this.duration);

  final String label;
  final String mqttValue;
  final Duration duration;

  /// MT4-style label for navigation and the period sidebar.
  String get displayLabel => switch (this) {
        ChartResolution.minute1 => 'M1',
        ChartResolution.minute5 => 'M5',
        ChartResolution.minute15 => 'M15',
        ChartResolution.minute30 => 'M30',
        ChartResolution.hour1 => 'H1',
        ChartResolution.hour2 => 'H2',
        ChartResolution.hour4 => 'H4',
        ChartResolution.hour6 => 'H6',
        ChartResolution.hour8 => 'H8',
        ChartResolution.day1 => 'D1',
        ChartResolution.week1 => 'W1',
        ChartResolution.month1 => 'MN',
      };

  static const defaultResolution = ChartResolution.minute1;
  static const initialBarCount = 200;

  /// Default number of bars visible on chart tab (zoomed-in view).
  int get initialVisibleBars => switch (this) {
        ChartResolution.minute1 => 90,
        ChartResolution.minute5 => 80,
        ChartResolution.minute15 => 70,
        ChartResolution.minute30 => 65,
        ChartResolution.hour1 => 60,
        ChartResolution.hour2 => 55,
        ChartResolution.hour4 => 50,
        ChartResolution.hour6 => 48,
        ChartResolution.hour8 => 45,
        ChartResolution.day1 => 45,
        ChartResolution.week1 => 40,
        ChartResolution.month1 => 36,
      };

  int barDurationMs() => duration.inMilliseconds;
}
