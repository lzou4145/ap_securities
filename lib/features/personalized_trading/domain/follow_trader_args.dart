/// Route arguments for [FollowTraderPage].
class FollowTraderArgs {
  const FollowTraderArgs({
    required this.singleAccountId,
    this.accountName = '',
    this.daysAmount = '',
    this.followWalletsTradeAmount = '',
    this.followCommissionRate = 0,
  });

  final int singleAccountId;
  final String accountName;
  final String daysAmount;
  final String followWalletsTradeAmount;
  final int followCommissionRate;

  String get displayName {
    final name = accountName.trim();
    if (name.isNotEmpty) return name;
    return '#$singleAccountId';
  }
}
