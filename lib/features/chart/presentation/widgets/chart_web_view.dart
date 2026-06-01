import 'package:ap_securities/features/chart/presentation/widgets/lightweight_candle_chart_web_view.dart';
import 'package:ap_securities/features/chart/providers/chart_providers.dart';
import 'package:ap_securities/features/market/domain/market_price_format.dart';
import 'package:ap_securities/features/market/providers/market_watchlist_notifier.dart';
import 'package:ap_securities/providers/app_shell_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Chart tab — MQTT candlesticks with live tick updates.
class ChartWebView extends ConsumerStatefulWidget {
  const ChartWebView({super.key});

  @override
  ConsumerState<ChartWebView> createState() => ChartWebViewState();
}

class ChartWebViewState extends ConsumerState<ChartWebView> {
  final _chartKey = GlobalKey<LightweightCandleChartWebViewState>();

  Future<void> fitContent() => _chartKey.currentState?.fitContent() ?? Future.value();

  Future<void> scrollToRealtime() =>
      _chartKey.currentState?.scrollToRealtime() ?? Future.value();

  @override
  Widget build(BuildContext context) {
    final chart = ref.watch(chartControllerProvider);
    final chartDark = ref.watch(chartThemeDarkProvider);
    ref.listen(chartThemeDarkProvider, (previous, next) {
      if (previous != next) {
        ref.read(chartControllerProvider.notifier).resetChartReady();
      }
    });
    final quotes = ref.watch(marketWatchlistProvider).valueOrNull;
    final decimalPlace = decimalPlaceForSymbol(quotes, chart.symbol ?? '');

    return LightweightCandleChartWebView(
      key: _chartKey,
      bars: chart.bars,
      chartReady: chart.chartReady,
      useDarkTheme: chartDark,
      decimalPlace: decimalPlace,
      seriesType: chart.seriesType,
      indicators: chart.indicators,
      initialVisibleBars: chart.resolution.initialVisibleBars,
      resolution: chart.resolution,
      onReady: () {
        ref.read(chartControllerProvider.notifier).markChartReady();
      },
      onNeedHistory: (fromMs, toMs) {
        ref.read(chartControllerProvider.notifier).loadMoreHistory(
              fromMs: fromMs,
              toMs: toMs,
            );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(chartControllerProvider.notifier).resetChartReady();
    });
  }
}
