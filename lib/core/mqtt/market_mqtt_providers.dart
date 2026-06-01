import 'package:ap_securities/core/mqtt/market_tick_mqtt_client.dart';
import 'package:ap_securities/features/account/providers/account_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final marketTickMqttClientProvider = Provider<MarketTickMqttClient>((ref) {
  final client = MarketTickMqttClient();
  ref.onDispose(client.dispose);
  return client;
});

final deviceNoProvider = FutureProvider<String>((ref) {
  return ref.watch(deviceNoServiceProvider).getDeviceNo();
});
