import 'package:ap_securities/features/trade/data/trade_summary_calculator.dart';
import 'package:ap_securities/features/trade/domain/open_position.dart';
import 'package:ap_securities/features/trade/domain/trade_side.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('margin is sum of position margins; equity includes floating', () {
    const positions = [
      OpenPosition(
        id: '1',
        symbol: 'XAUUSD',
        side: TradeSide.buy,
        volume: 1,
        priceFrom: 100,
        priceTo: 99,
        profit: -82,
        margin: 896.53,
      ),
      OpenPosition(
        id: '2',
        symbol: 'EURUSD',
        side: TradeSide.sell,
        volume: 0.01,
        priceFrom: 1.1,
        priceTo: 1.09,
        profit: 10,
        margin: 50,
      ),
    ];

    final summary = TradeSummaryCalculator.liveSummary(
      balance: 194069.70,
      positions: positions,
    );

    expect(summary.balance, closeTo(194069.70, 0.01));
    expect(summary.margin, closeTo(946.53, 0.01));
    expect(summary.equity, closeTo(194069.70 - 72, 0.01));
    expect(summary.freeMargin, closeTo(summary.equity - summary.margin, 0.01));
    expect(summary.marginLevelPercent, greaterThan(0));
  });
}
