import 'dart:async';
import 'dart:convert';

import 'package:ap_securities/core/mqtt/market_mqtt_providers.dart';
import 'package:ap_securities/core/mqtt/market_tick_mqtt_client.dart';
import 'package:ap_securities/core/mqtt/mqtt_tick_parser.dart';
import 'package:ap_securities/features/chart/domain/chart_defaults.dart';
import 'package:ap_securities/features/chart/domain/chart_indicator.dart';
import 'package:ap_securities/features/chart/domain/chart_resolution.dart';
import 'package:ap_securities/features/chart/domain/chart_series_type.dart';
import 'package:ap_securities/features/chart/domain/chart_state.dart';
import 'package:ap_securities/features/chart/domain/mqtt_history_result.dart';
import 'package:ap_securities/features/chart/providers/mqtt_candle_chart_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:ap_securities/features/chart/domain/chart_state.dart';

final chartControllerProvider =
    NotifierProvider<ChartController, ChartState>(ChartController.new);

class ChartController extends Notifier<ChartState> {
  var _historyGeneration = 0;
  var _loadingMore = false;
  int _lastLoadMoreAtMs = 0;
  int? _lastLoadMoreFromMs;

  MarketTickMqttClient get _mqtt => ref.read(marketTickMqttClientProvider);

  @override
  ChartState build() {
    return const ChartState(
      symbol: ChartDefaults.symbol,
      loading: true,
    );
  }

  void ensureLoaded() {
    final symbol = state.symbol ?? ChartDefaults.symbol;
    if (state.symbol != symbol) {
      openSymbol(symbol);
      return;
    }
    if (state.bars.isEmpty) {
      requestInitialHistoryForCurrentSymbol();
    }
  }

  void markChartReady() {
    state = state.copyWith(chartReady: true);
  }

  void resetChartReady() {
    state = state.copyWith(chartReady: false);
  }

  void openSymbol(String symbol) {
    if (symbol.isEmpty) return;
    _historyGeneration++;
    _loadingMore = false;
    _lastLoadMoreFromMs = null;
    state = ChartState(
      symbol: symbol,
      loading: true,
      chartReady: state.chartReady,
      seriesType: state.seriesType,
      indicators: state.indicators,
      resolution: state.resolution,
    );
    requestInitialHistoryForCurrentSymbol();
  }

  void setSeriesType(ChartSeriesType type) {
    if (state.seriesType == type) return;
    state = state.copyWith(seriesType: type);
  }

  void toggleIndicator(ChartIndicator indicator) {
    final next = Set<ChartIndicator>.from(state.indicators);
    if (next.contains(indicator)) {
      next.remove(indicator);
    } else {
      next.add(indicator);
    }
    state = state.copyWith(indicators: next);
  }

  void setResolution(ChartResolution resolution) {
    _historyGeneration++;
    _loadingMore = false;
    _lastLoadMoreFromMs = null;
    state = state.copyWith(
      resolution: resolution,
      loading: true,
      clearBars: true,
      earliestLoadedMs: null,
    );
    requestInitialHistoryForCurrentSymbol();
  }

  void applyHistoryForSymbol(MqttHistoryResult result) {
    final prevEarliest = state.earliestLoadedMs;
    state = MqttCandleChartOps.applyHistory(state, result);
    final nextEarliest = state.earliestLoadedMs;
    if (nextEarliest != null &&
        (prevEarliest == null || nextEarliest < prevEarliest)) {
      _lastLoadMoreFromMs = null;
    }
    _loadingMore = false;
  }

  void applyTick(MqttTickQuote tick) {
    state = MqttCandleChartOps.applyTick(state, tick);
  }

  void loadMoreHistory({required int fromMs, required int toMs}) {
    final symbol = state.symbol ?? ChartDefaults.symbol;
    if (_loadingMore || state.loading) return;
    if (!state.chartReady || !_mqtt.isConnected) return;

    final earliest = state.earliestLoadedMs;
    if (earliest == null) return;

    final batchMs =
        state.resolution.barDurationMs() * ChartResolution.initialBarCount;
    final effectiveToMs = earliest;
    final effectiveFromMs = effectiveToMs - batchMs;
    if (effectiveFromMs >= effectiveToMs) return;
    if (_lastLoadMoreFromMs == effectiveFromMs) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastLoadMoreAtMs < 600) return;
    _lastLoadMoreAtMs = now;
    _lastLoadMoreFromMs = effectiveFromMs;

    _loadingMore = true;
    final generation = _historyGeneration;
    MqttCandleChartOps.requestHistoryRange(
      mqtt: _mqtt,
      symbol: symbol,
      resolution: state.resolution,
      fromMs: effectiveFromMs,
      toMs: effectiveToMs,
    );
    Future<void>.delayed(const Duration(seconds: 8), () {
      if (generation == _historyGeneration) {
        _loadingMore = false;
      }
    });
  }

  void refreshHistory() {
    requestInitialHistoryForCurrentSymbol();
  }

  void requestInitialHistoryForCurrentSymbol() {
    state = state.copyWith(loading: true);
    MqttCandleChartOps.requestInitialHistory(mqtt: _mqtt, state: state);
  }

  String barsJson() {
    return jsonEncode(state.bars.map((b) => b.toChartJson()).toList());
  }
}
