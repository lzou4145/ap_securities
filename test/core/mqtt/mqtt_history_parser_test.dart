import 'package:ap_securities/core/mqtt/mqtt_history_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildRequest formats symbol resolution and range', () {
    expect(
      MqttHistoryParser.buildRequest(
        symbol: 'BTCUSDT',
        resolution: 'minute',
        fromMs: 1000,
        toMs: 2000,
      ),
      'BTCUSDT:minute:1000:2000',
    );
  });

  test('parsePushPayload reads semicolon-separated OHLCV bars', () {
    const raw =
        '1777781520000:78132.00:78132.01:78130.54:78130.54:9762.44:0.12;'
        '1777781580000:78130.54:78147.03:78130.54:78147.02:11804.38:0.15';

    final history = MqttHistoryParser.parsePushPayload(raw);
    expect(history, isNotNull);
    expect(history!.bars, hasLength(2));
    expect(history.bars.first.timeMs, 1777781520000);
    expect(history.bars.first.open, 78132.00);
    expect(history.bars.last.close, 78147.02);
  });
}
