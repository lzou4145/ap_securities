/// One real-time tick: `SYMBOL:timestampMs:bid:ask`.
class MqttTickQuote {
  const MqttTickQuote({
    required this.symbol,
    required this.timestampMs,
    required this.bid,
    required this.ask,
    required this.bidText,
    required this.askText,
  });

  final String symbol;
  final int timestampMs;
  final double bid;
  final double ask;

  /// Raw price strings from MQTT (display as-is).
  final String bidText;
  final String askText;
}

abstract final class MqttTickParser {
  /// Parses push payload `ETHUSDT:1779099368848:2113.69:2113.7`.
  static MqttTickQuote? parsePushPayload(String raw) {
    final payload = raw.trim();
    if (payload.isEmpty) return null;

    final parts = payload.split(':');
    if (parts.length != 4) return null;

    final timestampMs = int.tryParse(parts[1]);
    final bid = double.tryParse(parts[2]);
    final ask = double.tryParse(parts[3]);
    if (timestampMs == null || bid == null || ask == null) return null;

    return MqttTickQuote(
      symbol: parts[0],
      timestampMs: timestampMs,
      bid: bid,
      ask: ask,
      bidText: parts[2].trim(),
      askText: parts[3].trim(),
    );
  }

  /// Builds subscribe payload `BTCUSDT:ETHUSDT:EURUSD`.
  static String buildSubscribePayload(Iterable<String> symbols) {
    return symbols
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(':');
  }
}
