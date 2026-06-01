class HoldingRow {
  const HoldingRow({
    required this.name,
    required this.code,
    required this.quantity,
    required this.marketValue,
    required this.pnlPercent,
  });

  final String name;
  final String code;
  final int quantity;
  final double marketValue;
  final double pnlPercent;
}
