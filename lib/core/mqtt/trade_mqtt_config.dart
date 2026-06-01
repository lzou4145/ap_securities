import 'package:flutter/foundation.dart';

/// Broker settings for trade WebSocket MQTT.
abstract final class TradeMqttConfig {
  /// Force logs in release builds when diagnosing broker issues.
  static const bool verboseLogging = false;

  /// Logs in [kDebugMode] or when [verboseLogging] is true.
  static bool get loggingEnabled => kDebugMode || verboseLogging;

  static const String host = '43.198.76.61';
  static const int port = 8083;

  static const String websocketPath = '/mqtt';

  static const String tradePublishTopic = 'server/trade';

  /// WS URL for [mqtt_client] — scheme + host + path; set [port] on the client.
  static String get websocketServer {
    final path =
        websocketPath.isEmpty || websocketPath == '/' ? '' : websocketPath;
    return 'ws://$host$path';
  }

  /// Inbound trade notifications — `accountId` is [StoredAccount.accountId].
  static String pushTopic(String accountId) => 'push/$accountId';

  /// MQTT client id: `trade_{accountId}_{deviceNo}`.
  static String clientId({
    required String accountId,
    required String deviceNo,
  }) =>
      'trade_${accountId}_$deviceNo';
}
