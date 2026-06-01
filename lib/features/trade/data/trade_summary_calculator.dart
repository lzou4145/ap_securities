import 'package:ap_securities/features/trade/domain/open_position.dart';
import 'package:ap_securities/features/trade/domain/trade_account_summary.dart';

abstract final class TradeSummaryCalculator {
  /// [balance] — account balance (结余); [margin] — sum of open position margins.
  static TradeAccountSummary liveSummary({
    required double balance,
    required Iterable<OpenPosition> positions,
  }) {
    var totalMargin = 0.0;
    var totalFloating = 0.0;
    for (final p in positions) {
      totalMargin += p.margin;
      totalFloating += p.profit;
    }
    final equity = balance + totalFloating;
    final freeMargin = equity - totalMargin;
    final marginLevel =
        totalMargin > 0 ? (equity / totalMargin) * 100 : 0.0;
    return TradeAccountSummary(
      balance: balance,
      equity: equity,
      margin: totalMargin,
      freeMargin: freeMargin,
      marginLevelPercent: marginLevel,
    );
  }
}
