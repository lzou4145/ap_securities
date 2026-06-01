import 'dart:async';
import 'dart:convert';

import 'package:ap_securities/features/chart/data/lightweight_charts_embed.dart';
import 'package:ap_securities/features/chart/domain/chart_candle.dart';
import 'package:ap_securities/features/chart/domain/chart_indicator.dart';
import 'package:ap_securities/features/chart/domain/chart_resolution.dart';
import 'package:ap_securities/features/chart/domain/chart_series_type.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Lightweight Charts candlestick WebView driven by [bars] from MQTT.
class LightweightCandleChartWebView extends StatefulWidget {
  const LightweightCandleChartWebView({
    required this.bars,
    required this.chartReady,
    required this.onReady,
    required this.onNeedHistory,
    this.hideVolume = false,
    this.useBidAskLineChart = false,
    this.enableHistory = true,
    this.useDarkTheme = false,
    this.decimalPlace = 2,
    this.seriesType = ChartSeriesType.candles,
    this.indicators = const {},
    this.initialVisibleBars = 70,
    this.resolution = ChartResolution.defaultResolution,
    super.key,
  });

  final List<ChartCandle> bars;
  final bool chartReady;
  final VoidCallback onReady;
  final void Function(int fromMs, int toMs) onNeedHistory;
  final bool hideVolume;

  /// When true, renders bid (blue) and ask (red) lines (trade order page).
  final bool useBidAskLineChart;

  /// When false, ignores [onNeedHistory] (intraday live-only chart).
  final bool enableHistory;

  /// Chart tab dark candlestick theme.
  final bool useDarkTheme;

  /// Price axis precision from market watchlist `decimal_place`.
  final int decimalPlace;

  final ChartSeriesType seriesType;
  final Set<ChartIndicator> indicators;

  /// Chart tab: how many recent bars to show (zoom level).
  final int initialVisibleBars;

  /// Drives history pagination window when scrolling left.
  final ChartResolution resolution;

  @override
  State<LightweightCandleChartWebView> createState() =>
      LightweightCandleChartWebViewState();
}

class LightweightCandleChartWebViewState
    extends State<LightweightCandleChartWebView> {
  WebViewController? _controller;
  Widget? _platformView;
  String? _lastBarsJson;
  String? _lastPointJson;
  int? _lastTickBarTimeMs;
  double? _lastTickBid;
  double? _lastTickAsk;
  var _readyNotified = false;

  @override
  void initState() {
    super.initState();
    _initPlatformView();
  }

  @override
  void didUpdateWidget(LightweightCandleChartWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.useDarkTheme != widget.useDarkTheme &&
        !widget.useBidAskLineChart) {
      _reloadPlatformView();
      return;
    }
    if (oldWidget.bars != widget.bars) {
      _syncBars(oldWidget.bars, widget.bars);
    }
    if (!oldWidget.chartReady && widget.chartReady) {
      if (widget.useBidAskLineChart) {
        if (widget.bars.isNotEmpty) {
          _pushBars(force: true);
        }
      } else {
        _pushBars(force: true);
      }
    }
    if (!widget.useBidAskLineChart) {
      if (oldWidget.seriesType != widget.seriesType) {
        unawaited(_applySeriesType());
      }
      if (oldWidget.indicators != widget.indicators) {
        unawaited(_applyIndicators());
      }
    }
  }

  Future<void> fitContent() async {
    await _runJs('window.__chartApi && window.__chartApi.fitContent();');
  }

  Future<void> scrollToRealtime() async {
    await _runJs(
      'window.__chartApi && window.__chartApi.scrollToRealtime();',
    );
  }

  void _reloadPlatformView() {
    _readyNotified = false;
    _lastBarsJson = null;
    _lastPointJson = null;
    _lastTickBarTimeMs = null;
    _lastTickBid = null;
    _lastTickAsk = null;
    _initPlatformView();
    if (mounted) {
      setState(() {});
    }
  }

  void _initPlatformView() {
    final chartBg =
        widget.useDarkTheme ? const Color(0xFF131722) : Colors.white;
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(chartBg)
      ..addJavaScriptChannel(
        'ChartBridge',
        onMessageReceived: (message) => _onBridgeMessage(message.message),
      )
      ..loadHtmlString(
        widget.useBidAskLineChart
            ? LightweightChartsEmbed.tradeOrderBidAskLineChartHtml(
                decimalPlace: widget.decimalPlace,
              )
            : LightweightChartsEmbed.chartHtml(
                hideVolume: widget.hideVolume,
                isDark: widget.useDarkTheme,
                decimalPlace: widget.decimalPlace,
                seriesType: widget.seriesType.jsValue,
                indicatorsJson: _indicatorsJson(widget.indicators),
                initialVisibleBars: widget.initialVisibleBars,
                barDurationMs: widget.resolution.barDurationMs(),
                historyBatchBars: ChartResolution.initialBarCount,
              ),
        baseUrl: 'https://localhost',
      );

    _controller = controller;
    _platformView = WebViewWidget(
      key: ValueKey(
        'mqtt_chart_${widget.useBidAskLineChart}_'
        '${widget.hideVolume}_${widget.useDarkTheme}_'
        '${widget.decimalPlace}_${widget.seriesType.name}_'
        '${widget.initialVisibleBars}_${widget.resolution.name}',
      ),
      controller: controller,
    );
  }

  void _syncBars(List<ChartCandle> previous, List<ChartCandle> next) {
    if (widget.useBidAskLineChart) {
      _syncBidAskIntraday(previous, next);
      return;
    }
    if (_isOnlyLastBarChanged(previous, next)) {
      _updateLastBar(next.last);
      return;
    }
    _pushBars();
  }

  /// Live bid/ask chart — push only the latest point (incremental, no setData).
  void _syncBidAskIntraday(List<ChartCandle> previous, List<ChartCandle> next) {
    if (!widget.chartReady) return;

    if (next.isEmpty) {
      _lastPointJson = null;
      _lastBarsJson = null;
      unawaited(_runJs('window.__chartApi && window.__chartApi.setBars([]);'));
      return;
    }

    if (previous.isEmpty && next.length > 1) {
      _pushBars(force: true);
      return;
    }

    final last = next.last;
    final json = jsonEncode(last.toChartJson());
    if (json == _lastPointJson) return;
    _lastPointJson = json;

    unawaited(
      _runJs(
        'window.__chartApi && window.__chartApi.updatePoint($json);',
      ),
    );
  }

  static String _indicatorsJson(Set<ChartIndicator> indicators) {
    if (indicators.isEmpty) return '[]';
    final parts = indicators.map((e) => '"${e.jsValue}"').join(',');
    return '[$parts]';
  }

  Future<void> _applySeriesType() async {
    if (!widget.chartReady || widget.useBidAskLineChart) return;
    await _runJs(
      "window.__chartApi && window.__chartApi.setSeriesType('${widget.seriesType.jsValue}');",
    );
  }

  Future<void> _applyIndicators() async {
    if (!widget.chartReady || widget.useBidAskLineChart) return;
    await _runJs(
      'window.__chartApi && window.__chartApi.setIndicators(${_indicatorsJson(widget.indicators)});',
    );
  }

  Future<void> _runJs(String script) async {
    final controller = _controller;
    if (controller == null || !mounted) return;
    try {
      await controller.runJavaScript(script);
    } on Object {
      // WebView may be torn down while navigating away.
    }
  }

  bool _isOnlyLastBarChanged(List<ChartCandle> previous, List<ChartCandle> next) {
    if (previous.length != next.length || next.isEmpty) return false;
    if (previous.length <= 1) return false;
    for (var i = 0; i < previous.length - 1; i++) {
      final a = previous[i];
      final b = next[i];
      if (a.timeMs != b.timeMs ||
          a.open != b.open ||
          a.high != b.high ||
          a.low != b.low ||
          a.close != b.close ||
          a.bid != b.bid ||
          a.ask != b.ask) {
        return false;
      }
    }
    return previous.last.timeMs == next.last.timeMs;
  }

  void _onBridgeMessage(String raw) {
    if (!mounted) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final type = map['type'] as String?;
      switch (type) {
        case 'ready':
          if (!_readyNotified) {
            _readyNotified = true;
            if (mounted) {
              widget.onReady();
            }
          }
          if (!widget.useBidAskLineChart || widget.bars.isNotEmpty) {
            _pushBars(force: true);
          }
        case 'needHistory':
          if (!widget.enableHistory) return;
          final from = map['from'];
          final to = map['to'];
          if (from is! num || to is! num) return;
          if (mounted) {
            widget.onNeedHistory(from.toInt(), to.toInt());
          }
      }
    } on Object {
      // Ignore malformed bridge messages.
    }
  }

  Future<void> _pushBars({bool force = false}) async {
    final controller = _controller;
    if (controller == null || !mounted) return;
    if (!widget.chartReady && !force) return;

    final json = jsonEncode(widget.bars.map((b) => b.toChartJson()).toList());
    if (!force && json == _lastBarsJson) return;
    _lastBarsJson = json;
    _lastTickBarTimeMs = null;
    _lastTickBid = null;
    _lastTickAsk = null;

    try {
      await controller.runJavaScript(
        'window.__chartApi && window.__chartApi.setBars($json);',
      );
    } on Object {
      // WebView may be torn down while navigating away.
    }
  }

  Future<void> _updateLastBar(ChartCandle bar) async {
    final controller = _controller;
    if (controller == null || !mounted) return;
    if (!widget.chartReady) return;

    if (bar.timeMs == _lastTickBarTimeMs &&
        bar.bid == _lastTickBid &&
        bar.ask == _lastTickAsk) {
      return;
    }
    _lastTickBarTimeMs = bar.timeMs;
    _lastTickBid = bar.bid;
    _lastTickAsk = bar.ask;

    final json = jsonEncode(bar.toChartJson());
    try {
      await controller.runJavaScript(
        'window.__chartApi && window.__chartApi.updateBar($json);',
      );
    } on Object {
      // WebView may be torn down while navigating away.
    }
  }

  @override
  Widget build(BuildContext context) {
    return _platformView ?? const Center(child: CircularProgressIndicator());
  }
}
