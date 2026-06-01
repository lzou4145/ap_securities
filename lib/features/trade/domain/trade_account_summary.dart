/// Account metrics shown below the total P/L header on the trade tab.
class TradeAccountSummary {
  const TradeAccountSummary({
    required this.balance,
    required this.equity,
    required this.margin,
    required this.freeMargin,
    required this.marginLevelPercent,
  });

  final double balance;
  final double equity;
  final double margin;
  final double freeMargin;
  final double marginLevelPercent;
}
