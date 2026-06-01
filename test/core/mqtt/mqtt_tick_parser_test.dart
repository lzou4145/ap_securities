import 'package:ap_securities/core/mqtt/mqtt_tick_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parsePushPayload parses symbol timestamp bid ask', () {
    final tick = MqttTickParser.parsePushPayload(
      'ETHUSDT:1779099368848:2113.69:2113.7',
    );

    expect(tick, isNotNull);
    expect(tick!.symbol, 'ETHUSDT');
    expect(tick.timestampMs, 1779099368848);
    expect(tick.bid, 2113.69);
    expect(tick.ask, 2113.7);
    expect(tick.bidText, '2113.69');
    expect(tick.askText, '2113.7');
  });

  test('buildSubscribePayload joins symbols with colon', () {
    expect(
      MqttTickParser.buildSubscribePayload(['BTCUSDT', 'ETHUSDT', 'EURUSD']),
      'BTCUSDT:ETHUSDT:EURUSD',
    );
  });

}
