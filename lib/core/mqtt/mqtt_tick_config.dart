/// Broker settings for real-time tick WebSocket MQTT.
abstract final class MqttTickConfig {
  /// Set true only when debugging MQTT connection issues.
  static const bool verboseLogging = false;

  static const String host = '18.163.123.23';
  static const int port = 8083;

  /// WebSocket path on the broker (EMQX/Mosquitto commonly use `/mqtt`).
  static const String websocketPath = '/mqtt';

  static const String username = 'customer';
  static const String password = '2vRNo9Mg2STcmsXN';

  /// WS server for [mqtt_client] — scheme + host + path only; set [port] on the client.
  static String get websocketServer {
    final path =
        websocketPath.isEmpty || websocketPath == '/' ? '' : websocketPath;
    return 'ws://$host$path';
  }

  static String subscribeTopic(String deviceId) => 'tick/$deviceId';

  static String pushTopic(String deviceId) => 'push/tick/$deviceId';

  /// Intraday high/low — subscribe `SYM1:SYM2:…`, push `SYM:ts:high:low;…`.
  static String daySubscribeTopic(String deviceId) => 'day/$deviceId';

  static String dayPushTopic(String deviceId) => 'push/day/$deviceId';

  static String historyTopic(String deviceId) => 'history/$deviceId';

  static String pushHistoryTopic(String deviceId) => 'push/history/$deviceId';
}
