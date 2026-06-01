import 'package:ap_securities/features/market/domain/market_quote.dart';
import 'package:ap_securities/features/trade/domain/trade_symbol_quote.dart';

/// Maps app symbols to TradingView tickers and [TradeSymbolQuote] rows.
abstract final class TradeSymbolMapper {
  static const _tradingViewOverrides = <String, String>{
    'XAUUSD': 'OANDA:XAUUSD',
    'AUDCAD': 'OANDA:AUDCAD',
    'EURUSD': 'OANDA:EURUSD',
    'GBPUSD': 'OANDA:GBPUSD',
    'USDJPY': 'OANDA:USDJPY',
  };

  static String tradingViewSymbol(String symbol) {
    final override = _tradingViewOverrides[symbol];
    if (override != null) return override;
    if (symbol.endsWith('USDT')) return 'BINANCE:$symbol';
    return 'OANDA:$symbol';
  }

  static TradeSymbolQuote fromMarketQuote(MarketQuote quote) {
    return TradeSymbolQuote(
      symbol: quote.symbol,
      tradingViewSymbol: tradingViewSymbol(quote.symbol),
      bid: quote.bid,
      ask: quote.ask,
      defaultLot: 0.01,
    );
  }

  static TradeSymbolQuote fallback(String symbol) {
    return TradeSymbolQuote(
      symbol: symbol,
      tradingViewSymbol: tradingViewSymbol(symbol),
      bid: 0,
      ask: 0,
      defaultLot: 0.01,
    );
  }
}
