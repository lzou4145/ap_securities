import 'package:ap_securities/core/mqtt/mqtt_day_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseDayPushPayload parses semicolon-separated batch', () {
    const raw =
        'XAUUSD:1779840000000:4525.972:4475.985;XAGUSD:1779840000000:77.54152:74.62935;';

    final quotes = MqttDayParser.parseDayPushPayload(raw);
    expect(quotes, hasLength(2));

    expect(quotes[0].symbol, 'XAUUSD');
    expect(quotes[0].timestampMs, 1779840000000);
    expect(quotes[0].high, 4525.972);
    expect(quotes[0].low, 4475.985);

    expect(quotes[1].symbol, 'XAGUSD');
    expect(quotes[1].high, 77.54152);
    expect(quotes[1].low, 74.62935);
  });

  test('parseDaySegment rejects invalid segments', () {
    expect(MqttDayParser.parseDaySegment(''), isNull);
    expect(MqttDayParser.parseDaySegment('EURUSD:1:2'), isNull);
  });
}
