import 'dart:async';

import 'package:ap_securities/core/mqtt/market_mqtt_providers.dart';
import 'package:ap_securities/features/chart/providers/chart_providers.dart';
import 'package:ap_securities/features/chart/providers/mqtt_chart_symbols_provider.dart';
import 'package:ap_securities/features/chart/providers/trade_order_chart_providers.dart';
import 'package:ap_securities/features/market/providers/market_watchlist_notifier.dart';
import 'package:ap_securities/providers/active_account_scope.dart';
import 'package:ap_securities/providers/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keeps MQTT in sync with login / account switch / watchlist. Watch from [App].
final marketTickMqttLifecycleProvider = Provider<void>((ref) {
  final mqtt = ref.read(marketTickMqttClientProvider);
  var syncGeneration = 0;

  mqtt.onTick = (tick) {
    ref.read(marketWatchlistProvider.notifier).applyTick(tick);
    ref.read(chartControllerProvider.notifier).applyTick(tick);

    if (ref.exists(tradeOrderChartProvider(tick.symbol))) {
      ref.read(tradeOrderChartProvider(tick.symbol).notifier).applyTick(tick);
    }
  };

  mqtt.onDayHighLow = (quotes) {
    ref.read(marketWatchlistProvider.notifier).applyDayHighLowBatch(quotes);
  };

  mqtt.onHistory = (result) {
    ref.read(chartControllerProvider.notifier).applyHistoryForSymbol(result);
  };

  void publishSymbols() {
    final symbols = ref.read(mqttChartSymbolsProvider);
    if (symbols.isEmpty) return;
    mqtt.publishSymbolList(symbols.toList());
  }

  mqtt.onReconnected = () {
    publishSymbols();
    final chart = ref.read(chartControllerProvider);
    if (chart.symbol != null && (chart.loading || chart.bars.isEmpty)) {
      ref.read(chartControllerProvider.notifier).refreshHistory();
    }
  };

  ref.onDispose(() {
    mqtt.onReconnected = null;
  });

  Future<void> syncMqtt() async {
    final generation = ++syncGeneration;
    final auth = ref.read(authStateProvider);
    final scope = ref.read(activeAccountScopeProvider);

    if (auth is! AuthStateSignedIn || scope == null) {
      await mqtt.disconnect();
      return;
    }

    final deviceNo = await ref.read(deviceNoProvider.future);
    if (generation != syncGeneration) return;

    await mqtt.connect(deviceId: deviceNo);
    if (generation != syncGeneration) return;

    publishSymbols();

    final chart = ref.read(chartControllerProvider);
    if (chart.symbol != null && (chart.loading || chart.bars.isEmpty)) {
      ref.read(chartControllerProvider.notifier).refreshHistory();
    }

  }

  ref.listen(activeAccountScopeProvider, (previous, next) {
    if (previous == next) return;
    unawaited(syncMqtt());
  });

  ref.listen(mqttChartSymbolsProvider, (previous, next) {
    if (previous == next) return;
    publishSymbols();
  });

  unawaited(syncMqtt());
});
