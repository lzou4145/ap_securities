import 'dart:convert';

import 'package:ap_securities/features/auth/data/login_code_decoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decodeLoginCode extracts first 4 digits before __', () {
    final plain = '12345678__device_extra';
    final encoded = base64Encode(utf8.encode(plain));

    expect(decodeLoginCode(encoded), '1234');
  });

  test('decodeLoginCode skips non-digits before first digit run', () {
    final plain = 'abc9876__suffix';
    final encoded = base64Encode(utf8.encode(plain));

    expect(decodeLoginCode(encoded), '9876');
  });

  test('decodeLoginCode handles production-like payload', () {
    expect(decodeLoginCode('Mjk5OV9fMTIzNDU2'), '2999');
    expect(decodeLoginCodePlaintext('Mjk5OV9fMTIzNDU2'), '2999__123456');
  });

  test('decodeLoginCode throws when fewer than 4 digits', () {
    final encoded = base64Encode(utf8.encode('12__x'));

    expect(() => decodeLoginCode(encoded), throwsFormatException);
  });
}
