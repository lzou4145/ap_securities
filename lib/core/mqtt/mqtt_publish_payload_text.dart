import 'dart:convert';
import 'dart:typed_data';

import 'package:mqtt_client/mqtt_client.dart';

/// Decodes MQTT publish payload as UTF-8 (server messages are Chinese/ASCII).
///
/// [MqttPublishPayload.bytesToStringAsString] treats each byte as Latin-1 and
/// mangles UTF-8 text.
String mqttPublishPayloadToUtf8String(MqttPublishMessage message) {
  final buffer = message.payload.message;
  final bytes = Uint8List.fromList(buffer);
  return utf8.decode(bytes, allowMalformed: true);
}
