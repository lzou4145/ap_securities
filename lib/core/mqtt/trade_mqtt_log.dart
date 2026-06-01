import 'package:ap_securities/core/mqtt/trade_mqtt_config.dart';
import 'package:flutter/foundation.dart';

/// Trade MQTT diagnostics — enabled in debug builds and when [TradeMqttConfig.verboseLogging].
void tradeMqttLog(String message) {
  if (kDebugMode || TradeMqttConfig.verboseLogging) {
    debugPrint('[TradeMQTT] $message');
  }
}
