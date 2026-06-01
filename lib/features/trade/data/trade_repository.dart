import 'package:ap_securities/features/trade/domain/open_position.dart';
import 'package:ap_securities/features/trade/domain/trade_account_summary.dart';
import 'package:ap_securities/features/trade/domain/trade_page_data.dart';
import 'package:ap_securities/features/trade/domain/trade_side.dart';

/// Mock trade API — replace [fetchTradePage] with real HTTP when ready.
class TradeRepository {
  Future<TradePageData> fetchTradePage() async {
    await Future<void>.delayed(const Duration(milliseconds: 380));
    return const TradePageData(
      totalProfitUsd: -74527.33,
      summary: TradeAccountSummary(
        balance: 194069.70,
        equity: 119542.37,
        margin: 11752.14,
        freeMargin: 107790.23,
        marginLevelPercent: 1017.20,
      ),
      positions: _mockPositions,
      followPositions: [],
    );
  }

  static const List<OpenPosition> _mockPositions = [
    OpenPosition(
      id: '1',
      symbol: 'AUDCAD',
      side: TradeSide.sell,
      volume: 0.01,
      priceFrom: 0.95478,
      priceTo: 0.94863,
      profit: 4.51,
      margin: 100,
    ),
    OpenPosition(
      id: '2',
      symbol: 'AUDCAD',
      side: TradeSide.sell,
      volume: 0.01,
      priceFrom: 0.95478,
      priceTo: 0.94863,
      profit: 4.51,
      margin: 100,
    ),
    OpenPosition(
      id: '3',
      symbol: 'XAUUSD',
      side: TradeSide.buy,
      volume: 2,
      priceFrom: 0.95478,
      priceTo: 0.94863,
      profit: -70710.00,
      margin: 896.53,
    ),
    OpenPosition(
      id: '4',
      symbol: 'AUDCAD',
      side: TradeSide.sell,
      volume: 0.01,
      priceFrom: 0.95478,
      priceTo: 0.94863,
      profit: 4.51,
      margin: 100,
    ),
    OpenPosition(
      id: '5',
      symbol: 'AUDCAD',
      side: TradeSide.sell,
      volume: 0.01,
      priceFrom: 0.95478,
      priceTo: 0.94863,
      profit: 4.51,
      margin: 100,
    ),
    OpenPosition(
      id: '6',
      symbol: 'XAUUSD',
      side: TradeSide.buy,
      volume: 2,
      priceFrom: 0.95478,
      priceTo: 0.94863,
      profit: -70710.00,
      margin: 896.53,
    ),
    OpenPosition(
      id: '7',
      symbol: 'AUDCAD',
      side: TradeSide.sell,
      volume: 0.01,
      priceFrom: 0.95478,
      priceTo: 0.94863,
      profit: 4.51,
      margin: 100,
    ),
  ];
}
