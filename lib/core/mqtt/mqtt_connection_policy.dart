/// Shared MQTT connection health thresholds.
abstract final class MqttConnectionPolicy {
  /// No inbound activity for this long → force reconnect (market ticks).
  static const Duration marketStaleTimeout = Duration(seconds: 60);

  /// No inbound activity for this long → force reconnect (trade push).
  static const Duration tradeStaleTimeout = Duration(seconds: 60);

  static const Duration healthCheckInterval = Duration(seconds: 30);
}
