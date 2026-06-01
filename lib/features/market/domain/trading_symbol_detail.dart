/// Instrument specification rows for the symbol detail screen.
class TradingSymbolDetail {
  const TradingSymbolDetail({
    required this.symbol,
    required this.rows,
  });

  final String symbol;
  final List<TradingSymbolDetailRow> rows;
}

class TradingSymbolDetailRow {
  const TradingSymbolDetailRow({
    required this.field,
    required this.value,
  });

  final SymbolDetailField field;
  final String value;
}

enum SymbolDetailField {
  spread,
  digits,
  stopLevel,
  contractSize,
  profitCalculation,
  marginCalculation,
  marginHedging,
  marginPercentage,
  gtcPending,
  swapType,
  swapLong,
  swapShort,
}
