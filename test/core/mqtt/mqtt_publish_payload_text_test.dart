import 'dart:convert';
import 'dart:typed_data';

import 'package:ap_securities/core/mqtt/mqtt_publish_payload_text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart';

void main() {
  test('decodes UTF-8 Chinese from publish payload', () {
    final payload = MqttPublishPayload()
      ..message.addAll(utf8.encode('TRADE_BACK|1002::可用余额不足'));
    final message = MqttPublishMessage()..payload = payload;

    expect(
      mqttPublishPayloadToUtf8String(message),
      'TRADE_BACK|1002::可用余额不足',
    );
  });
}
