import 'package:ap_securities/core/api/models/api_models_order.dart';
import 'package:ap_securities/features/history/domain/trade_history_record.dart';

/// Aggregates [HistorySummary] from closed orders in the selected period.
abstract final class HistorySummaryCalculator {
  /// [act_type] 2/3 are fund in/out when present; otherwise rows are trades.
  static const int actTypeDeposit = 2;
  static const int actTypeWithdrawal = 3;

  static HistorySummary fromOrders(Iterable<OrderHistoryItem> items) {
    var profit = 0.0;
    var credit = 0.0;
    var deposit = 0.0;
    var withdrawal = 0.0;

    for (final item in items) {
      switch (item.actType) {
        case actTypeDeposit:
          deposit += _amountMagnitude(item);
        case actTypeWithdrawal:
          withdrawal += _amountMagnitude(item);
        default:
          profit += _dbl(item.profitLoss);
          credit += _dbl(item.bail);
      }
    }

    return HistorySummary(
      profit: profit,
      credit: credit,
      deposit: deposit,
      withdrawal: withdrawal,
      balance: profit + deposit - withdrawal,
    );
  }

  static double _amountMagnitude(OrderHistoryItem item) {
    final amount = _dbl(item.amount);
    if (amount != 0) return amount.abs();
    return _dbl(item.profitLoss).abs();
  }

  static double _dbl(String raw) => double.tryParse(raw.trim()) ?? 0;
}
