/// Global hook for token-invalid (`-100` / `-101`) responses.
///
/// Wired from [SessionExpiredBinder] at app start so [AppHttpClient] can
/// trigger sign-out without a Riverpod cycle.
abstract final class SessionExpiredHost {
  static Future<void> Function()? onSessionExpired;
}
