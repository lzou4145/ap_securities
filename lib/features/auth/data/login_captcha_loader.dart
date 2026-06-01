import 'package:ap_securities/core/api/models/api_models_auth.dart';
import 'package:ap_securities/features/auth/data/login_captcha_parser.dart';
import 'package:ap_securities/features/auth/data/login_code_decoder.dart';
import 'package:ap_securities/features/auth/domain/login_captcha_challenge.dart';

/// Builds [LoginCaptchaChallenge] from `getLoginCode` response `code`.
LoginCaptchaChallenge loadLoginCaptchaChallenge(LoginCodeData payload) {
  final raw = payload.code.trim();
  if (raw.isEmpty) {
    throw const FormatException('login code is empty');
  }

  final imageBytes = LoginCaptchaParser.imageBytesFromLoginCodeResponse(
    code: raw,
    image: payload.image,
    img: payload.img,
  );
  if (imageBytes != null) {
    return LoginCaptchaChallenge(rawCode: raw, imageBytes: imageBytes);
  }

  final textCaptcha = decodeLoginCode(raw);
  return LoginCaptchaChallenge(rawCode: raw, textCaptcha: textCaptcha);
}
