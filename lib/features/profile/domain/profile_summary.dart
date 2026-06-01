/// User profile shown on the settings screen.
class ProfileSummary {
  const ProfileSummary({
    required this.accountName,
    required this.accountId,
  });

  /// Display name (用户名).
  final String accountName;

  /// Trading account ID (用户ID).
  final String accountId;
}
