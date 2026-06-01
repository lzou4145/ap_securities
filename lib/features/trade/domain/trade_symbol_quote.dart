/// Live quote and chart mapping for a tradable symbol on the order screen.
class TradeSymbolQuote {
  const TradeSymbolQuote({
    required this.symbol,
    required this.tradingViewSymbol,
    required this.bid,
    required this.ask,
    required this.defaultLot,
  });

  final String symbol;
  final String tradingViewSymbol;
  final double bid;
  final double ask;
  final double defaultLot;
}

