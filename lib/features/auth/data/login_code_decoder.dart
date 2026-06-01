import 'dart:convert';

/// UTF-8 plaintext from `getLoginCode` `code` after Base64 decode.
String decodeLoginCodePlaintext(String encoded) {
  final trimmed = encoded.trim();
  if (trimmed.isEmpty) {
    throw const FormatException('login code is empty');
  }
  return utf8.decode(base64Decode(trimmed));
}

/// Decodes [encoded] from `getLoginCode`: Base64 → split on `__` → first 4 digits.
String decodeLoginCode(String encoded) {
  final firstSegment = decodeLoginCodePlaintext(encoded).split('__').first;
  final digits = RegExp(r'\d')
      .allMatches(firstSegment)
      .map((m) => m.group(0)!)
      .take(4)
      .join();

  if (digits.length < 4) {
    throw FormatException(
      'login code segment has fewer than 4 digits: $firstSegment',
    );
  }
  return digits;
}
