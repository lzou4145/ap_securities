import 'package:ap_securities/features/history/domain/history_period.dart';

/// Single closed trade row on the history list.
class TradeHistoryRecord {
  const TradeHistoryRecord({
    required this.id,
    required this.symbol,
    required this.side,
    required this.volume,
    required this.openPrice,
    required this.closePrice,
    required this.closedAt,
    required this.profit,
    this.takeProfit = 0,
    this.stopLoss = 0,
    this.fee = 0,
    this.overnightFee = 0,
    this.tax = 0,
  });

  final String id;
  final String symbol;
  final TradeSide side;
  final double volume;
  final double openPrice;
  final double closePrice;
  final DateTime closedAt;
  final double profit;
  final double takeProfit;
  final double stopLoss;
  final double fee;
  final double overnightFee;
  final double tax;
}

/// Account summary block below the trade list.
class HistorySummary {
  const HistorySummary({
    required this.profit,
    required this.credit,
    required this.deposit,
    required this.withdrawal,
    required this.balance,
  });

  final double profit;
  final double credit;
  final double deposit;
  final double withdrawal;
  final double balance;
}

/// API-shaped payload for the history screen.
class HistoryPageData {
  const HistoryPageData({
    required this.period,
    required this.records,
    required this.summary,
  });

  final HistoryPeriod period;
  final List<TradeHistoryRecord> records;
  final HistorySummary summary;
}
