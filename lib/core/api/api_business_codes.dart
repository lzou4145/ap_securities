/// APP-api business `code` values shared across the client.
abstract final class ApiBusinessCodes {
  /// Token missing or expired.
  static const int tokenInvalid = -100;

  /// Token invalid (alternate).
  static const int tokenInvalidAlt = -101;

  static bool isTokenInvalid(int code) =>
      code == tokenInvalid || code == tokenInvalidAlt;
}
