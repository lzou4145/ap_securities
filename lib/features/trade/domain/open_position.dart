import 'package:ap_securities/features/trade/domain/trade_side.dart';

/// An open position on the trade tab.
class OpenPosition {
  const OpenPosition({
    required this.id,
    required this.symbol,
    required this.side,
    required this.volume,
    required this.priceFrom,
    required this.priceTo,
    required this.profit,
    required this.margin,
    this.takeProfit = 0,
    this.stopLoss = 0,
    this.fee = 0,
    this.overnightFee = 0,
    this.tax = 0,
    this.timestampSec = 0,
    this.leaderId = '',
  });

  final String id;
  final String symbol;
  final TradeSide side;
  final double volume;
  final double priceFrom;
  final double priceTo;
  final double profit;
  final double margin;
  final double takeProfit;
  final double stopLoss;
  final double fee;
  final double overnightFee;
  final double tax;
  final int timestampSec;

  /// Signal provider id from MQTT; non-empty and non-zero means copy-trade.
  final String leaderId;

  bool get isFollowPosition {
    final id = leaderId.trim();
    if (id.isEmpty || id == '0') return false;
    return true;
  }
}
