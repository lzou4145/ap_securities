import 'package:ap_securities/features/chart/domain/chart_state.dart';
import 'package:ap_securities/features/chart/presentation/widgets/lightweight_candle_chart_web_view.dart';
import 'package:ap_securities/features/chart/providers/trade_order_chart_providers.dart';
import 'package:ap_securities/features/market/domain/market_price_format.dart';
import 'package:ap_securities/features/market/providers/market_watchlist_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Trade order screen — intraday bid/ask lines from live MQTT ticks only.
class TradeOrderCandleChart extends ConsumerStatefulWidget {
  const TradeOrderCandleChart({
    required this.symbol,
    super.key,
  });

  final String symbol;

  @override
  ConsumerState<TradeOrderCandleChart> createState() =>
      _TradeOrderCandleChartState();
}

class _TradeOrderCandleChartState extends ConsumerState<TradeOrderCandleChart> {
  ChartState _chart = const ChartState();
  ProviderSubscription<ChartState>? _chartSub;

  @override
  void initState() {
    super.initState();
    if (widget.symbol.isNotEmpty) {
      _chartSub = ref.listenManual(
        tradeOrderChartProvider(widget.symbol),
        (previous, next) {
          if (previous?.bars != next.bars ||
              previous?.chartReady != next.chartReady) {
            setState(() => _chart = next);
          }
        },
        fireImmediately: true,
      );
    }
  }

  @override
  void didUpdateWidget(TradeOrderCandleChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol == widget.symbol) return;

    _chartSub?.close();
    _chartSub = null;
    _chart = const ChartState();

    if (widget.symbol.isEmpty) return;

    _chartSub = ref.listenManual(
      tradeOrderChartProvider(widget.symbol),
      (previous, next) {
        if (previous?.bars != next.bars ||
            previous?.chartReady != next.chartReady) {
          setState(() => _chart = next);
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _chartSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.symbol.isEmpty) {
      return const ColoredBox(
        color: Colors.white,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final quotes = ref.watch(marketWatchlistProvider).valueOrNull;
    final decimalPlace = decimalPlaceForSymbol(quotes, widget.symbol);

    return LightweightCandleChartWebView(
      key: ValueKey<String>(
        'trade_order_chart_${widget.symbol}_$decimalPlace',
      ),
      bars: _chart.bars,
      chartReady: _chart.chartReady,
      useBidAskLineChart: true,
      enableHistory: false,
      decimalPlace: decimalPlace,
      onReady: () {
        if (!mounted) return;
        ref
            .read(tradeOrderChartProvider(widget.symbol).notifier)
            .markChartReady();
      },
      onNeedHistory: (_, __) {},
    );
  }
}
