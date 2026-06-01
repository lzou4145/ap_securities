import 'package:ap_securities/core/assets/app_icons.dart';

/// Main series style for MQTT Lightweight Charts (chart tab).
enum ChartSeriesType {
  candles,
  hollowCandles,
  line,
  area,
  bars,
}

extension ChartSeriesTypeX on ChartSeriesType {
  String get jsValue => switch (this) {
        ChartSeriesType.candles => 'candles',
        ChartSeriesType.hollowCandles => 'hollowCandles',
        ChartSeriesType.line => 'line',
        ChartSeriesType.area => 'area',
        ChartSeriesType.bars => 'bars',
      };

  /// Chart type picker + app bar button icon.
  String get iconAsset => switch (this) {
        ChartSeriesType.candles => AppIcons.svgChartToolBars,
        ChartSeriesType.hollowCandles => AppIcons.svgChartToolHbars,
        ChartSeriesType.line => AppIcons.svgChartToolRealtime,
        ChartSeriesType.area => AppIcons.svgChartToolFit,
        ChartSeriesType.bars => AppIcons.svgChartToolIndicator,
      };
}
