import 'dart:async';

import 'package:ap_securities/core/mqtt/market_mqtt_providers.dart';
import 'package:ap_securities/features/trade/providers/trade_mqtt_providers.dart';
import 'package:ap_securities/providers/auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool mqttHasUsableNetwork(List<ConnectivityResult> results) {
  return results.any((r) => r != ConnectivityResult.none);
}

/// Reconnect market + trade MQTT immediately when network comes back.
///
/// Weak network / no push data: each MQTT client forces reconnect after
/// MqttConnectionPolicy stale timeout (60s), not on a global timer.
final mqttNetworkWatchProvider = Provider<void>((ref) {
  final market = ref.read(marketTickMqttClientProvider);
  final trade = ref.read(tradeMqttClientProvider);

  Future<void> resyncAll() async {
    if (ref.read(authStateProvider) is! AuthStateSignedIn) return;
    await market.reconnectIfNeeded();
    await trade.reconnectIfNeeded();
  }

  final connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? connectivitySub;
  var hadNetwork = true;

  unawaited(
    connectivity.checkConnectivity().then((results) {
      hadNetwork = mqttHasUsableNetwork(results);
    }),
  );

  connectivitySub = connectivity.onConnectivityChanged.listen((results) {
    final hasNetwork = mqttHasUsableNetwork(results);
    if (hasNetwork && !hadNetwork) {
      unawaited(resyncAll());
    }
    hadNetwork = hasNetwork;
  });

  ref.onDispose(() {
    connectivitySub?.cancel();
  });
});
