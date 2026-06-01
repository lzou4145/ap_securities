/// Intraday high/low from `push/day/{deviceId}` — `SYM:ts:high:low;…`.
class MqttDayQuote {
  const MqttDayQuote({
    required this.symbol,
    required this.timestampMs,
    required this.high,
    required this.low,
  });

  final String symbol;
  final int timestampMs;
  final double high;
  final double low;
}

abstract final class MqttDayParser {
  /// Parses `XAUUSD:1779840000000:4525.972:4475.985;XAGUSD:…`.
  static List<MqttDayQuote> parseDayPushPayload(String raw) {
    final payload = raw.trim();
    if (payload.isEmpty) return const [];

    final quotes = <MqttDayQuote>[];
    for (final segment in payload.split(';')) {
      final quote = parseDaySegment(segment);
      if (quote != null) quotes.add(quote);
    }
    return quotes;
  }

  /// Parses one `SYMBOL:timestampMs:high:low` segment.
  static MqttDayQuote? parseDaySegment(String raw) {
    final segment = raw.trim();
    if (segment.isEmpty) return null;

    final parts = segment.split(':');
    if (parts.length != 4) return null;

    final timestampMs = int.tryParse(parts[1]);
    final high = double.tryParse(parts[2]);
    final low = double.tryParse(parts[3]);
    if (timestampMs == null || high == null || low == null) return null;

    return MqttDayQuote(
      symbol: parts[0],
      timestampMs: timestampMs,
      high: high,
      low: low,
    );
  }
}
