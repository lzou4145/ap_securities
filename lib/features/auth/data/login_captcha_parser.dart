import 'dart:convert';
import 'dart:typed_data';

import 'package:ap_securities/features/auth/data/login_code_decoder.dart';

/// Parses image captcha bytes from `getLoginCode` payload fields.
abstract final class LoginCaptchaParser {
  /// Tries dedicated image fields, then segments inside Base64-decoded `code`.
  static Uint8List? imageBytesFromLoginCodeResponse({
    required String code,
    String? image,
    String? img,
  }) {
    for (final candidate in [image, img]) {
      final bytes = imageBytesFromPayload(candidate);
      if (bytes != null) return bytes;
    }

    try {
      final plain = decodeLoginCodePlaintext(code);
      for (final segment in plain.split('__')) {
        final bytes = imageBytesFromPayload(segment);
        if (bytes != null) return bytes;
      }
    } on FormatException {
      // Fall through to raw base64 image attempt.
    }

    return imageBytesFromPayload(code);
  }

  static Uint8List? imageBytesFromPayload(String? raw) {
    if (raw == null) return null;
    var payload = raw.trim();
    if (payload.isEmpty) return null;

    if (payload.startsWith('data:')) {
      final comma = payload.indexOf(',');
      if (comma >= 0) {
        payload = payload.substring(comma + 1).trim();
      }
    }

    try {
      final bytes = base64Decode(payload);
      return _isLikelyImage(bytes) ? bytes : null;
    } on FormatException {
      return null;
    }
  }

  static bool _isLikelyImage(Uint8List bytes) {
    if (bytes.length < 4) return false;
    // PNG
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return true;
    }
    // JPEG
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return true;
    // GIF
    if (bytes.length >= 6 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46) {
      return true;
    }
    // WebP (RIFF....WEBP)
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return true;
    }
    // BMP
    if (bytes[0] == 0x42 && bytes[1] == 0x4D) return true;
    return false;
  }
}
