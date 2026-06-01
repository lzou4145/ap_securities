import 'dart:convert';
import 'dart:typed_data';

import 'package:ap_securities/features/auth/data/login_captcha_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('imageBytesFromPayload decodes PNG base64', () {
    const pngHeader = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    final bytes = Uint8List.fromList([...pngHeader, 0, 0, 0]);
    final encoded = base64Encode(bytes);

    final parsed = LoginCaptchaParser.imageBytesFromPayload(encoded);
    expect(parsed, isNotNull);
    expect(parsed!.length, bytes.length);
  });

  test('imageBytesFromPayload supports data URL prefix', () {
    const pngHeader = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    final bytes = Uint8List.fromList([...pngHeader, 1, 2]);
    final encoded =
        'data:image/png;base64,${base64Encode(bytes)}';

    expect(
      LoginCaptchaParser.imageBytesFromPayload(encoded),
      isNotNull,
    );
  });

  test('imageBytesFromPayload returns null for non-image text payload', () {
    final encoded = base64Encode(utf8.encode('1234__device'));

    expect(LoginCaptchaParser.imageBytesFromPayload(encoded), isNull);
  });

  test('imageBytesFromLoginCodeResponse prefers image field', () {
    const pngHeader = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    final imageBytes = Uint8List.fromList([...pngHeader, 9]);
    final imageB64 = base64Encode(imageBytes);

    final parsed = LoginCaptchaParser.imageBytesFromLoginCodeResponse(
      code: 'session-key-only',
      image: imageB64,
    );

    expect(parsed, imageBytes);
  });
}
