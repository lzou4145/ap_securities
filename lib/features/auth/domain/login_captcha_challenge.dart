import 'dart:typed_data';

/// Captcha payload from `getLoginCode` ready for the login UI.
class LoginCaptchaChallenge {
  const LoginCaptchaChallenge({
    required this.rawCode,
    this.imageBytes,
    this.textCaptcha,
  }) : assert(imageBytes != null || textCaptcha != null);

  /// Original `code` from API (Base64), kept for the login request context.
  final String rawCode;

  final Uint8List? imageBytes;

  /// Plaintext captcha when API returns `digits__suffix` after Base64 decode.
  final String? textCaptcha;
}
