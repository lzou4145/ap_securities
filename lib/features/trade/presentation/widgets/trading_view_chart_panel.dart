import 'package:ap_securities/features/chart/data/trading_view_embed.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Embedded TradingView chart for a single symbol; reloads when [symbol] changes.
class TradingViewChartPanel extends StatefulWidget {
  const TradingViewChartPanel({
    required this.tradingViewSymbol,
    super.key,
  });

  final String tradingViewSymbol;

  @override
  State<TradingViewChartPanel> createState() => _TradingViewChartPanelState();
}

class _TradingViewChartPanelState extends State<TradingViewChartPanel> {
  WebViewController? _controller;
  var _loadedSymbol = '';

  @override
  void didUpdateWidget(TradingViewChartPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tradingViewSymbol != widget.tradingViewSymbol) {
      _loadChart();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadChart();
  }

  void _loadChart() {
    final symbol = widget.tradingViewSymbol;
    if (symbol.isEmpty) return;
    _loadedSymbol = symbol;
    final html = TradingViewEmbed.compactIntradayChartHtml(symbol: symbol);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..loadHtmlString(html, baseUrl: 'https://www.tradingview.com');
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null || _loadedSymbol != widget.tradingViewSymbol) {
      return const ColoredBox(
        color: Colors.white,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return ColoredBox(
      color: Colors.white,
      child: WebViewWidget(controller: c),
    );
  }
}
