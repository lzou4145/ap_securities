import 'package:ap_securities/core/api/models/api_models_auth.dart';
import 'package:ap_securities/features/auth/data/login_captcha_loader.dart';
import 'package:ap_securities/features/auth/data/login_code_decoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loadLoginCaptchaChallenge decodes API sample code', () {
    const encoded = 'Mjk5OV9fMTIzNDU2';

    expect(decodeLoginCode(encoded), '2999');
    expect(decodeLoginCodePlaintext(encoded), '2999__123456');

    final challenge = loadLoginCaptchaChallenge(
      const LoginCodeData(code: encoded),
    );

    expect(challenge.rawCode, encoded);
    expect(challenge.imageBytes, isNull);
    expect(challenge.textCaptcha, '2999');
  });
}
