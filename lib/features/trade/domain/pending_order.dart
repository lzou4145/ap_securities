import 'package:ap_securities/features/trade/domain/trade_side.dart';

/// Pending (limit/stop) order on the trade tab.
enum PendingOrderKind {
  buyLimit,
  sellLimit,
  buyStop,
  sellStop,
}

class PendingOrder {
  const PendingOrder({
    required this.id,
    required this.symbol,
    required this.kind,
    required this.lot,
    required this.limitPrice,
    required this.currentPrice,
    this.takeProfit = 0,
    this.stopLoss = 0,
    this.fee = 0,
    this.overnightFee = 0,
    this.tax = 0,
    this.createdAt = '',
  });

  final String id;
  final String symbol;
  final PendingOrderKind kind;
  final double lot;
  final double limitPrice;
  final double currentPrice;
  final double takeProfit;
  final double stopLoss;
  final double fee;
  final double overnightFee;
  final double tax;
  final String createdAt;

  TradeSide get side => switch (kind) {
        PendingOrderKind.buyLimit || PendingOrderKind.buyStop => TradeSide.buy,
        PendingOrderKind.sellLimit || PendingOrderKind.sellStop => TradeSide.sell,
      };

  bool get isBuy => side == TradeSide.buy;
}
