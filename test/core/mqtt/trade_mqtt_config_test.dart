import 'package:ap_securities/core/mqtt/trade_mqtt_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clientId uses accountId and deviceNo with underscores', () {
    expect(
      TradeMqttConfig.clientId(
        accountId: '1000071',
        deviceNo: 'device-abc',
      ),
      'trade_1000071_device-abc',
    );
  });
}
