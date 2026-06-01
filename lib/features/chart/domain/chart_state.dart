import 'package:ap_securities/features/chart/domain/chart_candle.dart';
import 'package:ap_securities/features/chart/domain/chart_indicator.dart';
import 'package:ap_securities/features/chart/domain/chart_resolution.dart';
import 'package:ap_securities/features/chart/domain/chart_series_type.dart';

class ChartState {
  const ChartState({
    this.symbol,
    this.resolution = ChartResolution.defaultResolution,
    this.bars = const [],
    this.loading = false,
    this.chartReady = false,
    this.earliestLoadedMs,
    this.seriesType = ChartSeriesType.candles,
    this.indicators = const {},
  });

  final String? symbol;
  final ChartResolution resolution;
  final List<ChartCandle> bars;
  final bool loading;
  final bool chartReady;
  final int? earliestLoadedMs;
  final ChartSeriesType seriesType;
  final Set<ChartIndicator> indicators;

  ChartState copyWith({
    String? symbol,
    ChartResolution? resolution,
    List<ChartCandle>? bars,
    bool? loading,
    bool? chartReady,
    int? earliestLoadedMs,
    ChartSeriesType? seriesType,
    Set<ChartIndicator>? indicators,
    bool clearBars = false,
  }) {
    return ChartState(
      symbol: symbol ?? this.symbol,
      resolution: resolution ?? this.resolution,
      bars: clearBars ? const [] : (bars ?? this.bars),
      loading: loading ?? this.loading,
      chartReady: chartReady ?? this.chartReady,
      earliestLoadedMs: earliestLoadedMs ?? this.earliestLoadedMs,
      seriesType: seriesType ?? this.seriesType,
      indicators: indicators ?? this.indicators,
    );
  }
}
