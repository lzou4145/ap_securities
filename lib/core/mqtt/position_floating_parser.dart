import 'package:ap_securities/features/trade/domain/open_position.dart';
import 'package:ap_securities/features/trade/domain/trade_side.dart';

/// One row from `POSITION_FLOATING_BACK|account:symbol:order:…`.
class PositionFloatingUpdate {
  const PositionFloatingUpdate({
    required this.accountId,
    required this.symbol,
    required this.orderId,
    required this.side,
    required this.lot,
    required this.takeProfit,
    required this.stopLoss,
    required this.openPrice,
    required this.currentPrice,
    required this.floatingPnl,
    required this.margin,
    required this.fee,
    required this.overnightFee,
    required this.timestampSec,
    required this.leaderId,
  });

  final String accountId;
  final String symbol;
  final String orderId;
  final TradeSide side;
  final double lot;
  final double takeProfit;
  final double stopLoss;
  final double openPrice;
  final double currentPrice;
  final double floatingPnl;
  final double margin;
  final double fee;
  final double overnightFee;
  final int timestampSec;
  final String leaderId;

  OpenPosition toOpenPosition() {
    return OpenPosition(
      id: orderId,
      symbol: symbol,
      side: side,
      volume: lot,
      priceFrom: openPrice,
      priceTo: currentPrice,
      profit: floatingPnl,
      margin: margin,
      takeProfit: takeProfit,
      stopLoss: stopLoss,
      fee: fee,
      overnightFee: overnightFee,
      timestampSec: timestampSec,
      leaderId: leaderId,
    );
  }
}

abstract final class PositionFloatingParser {
  static const String prefix = 'POSITION_FLOATING_BACK|';

  static PositionFloatingUpdate? tryParsePayload(String payload) {
    final trimmed = payload.trim();
    if (!trimmed.startsWith(prefix)) return null;
    return parseData(trimmed.substring(prefix.length));
  }

  static PositionFloatingUpdate? parseData(String data) {
    final parts = data.split(':');
    if (parts.length < 15) return null;

    final sideRaw = int.tryParse(parts[3]);
    final side = sideRaw == 1
        ? TradeSide.buy
        : sideRaw == 2
            ? TradeSide.sell
            : null;
    if (side == null) return null;

    return PositionFloatingUpdate(
      accountId: parts[0],
      symbol: parts[1],
      orderId: parts[2],
      side: side,
      lot: _dbl(parts[4]),
      takeProfit: _dbl(parts[5]),
      stopLoss: _dbl(parts[6]),
      openPrice: _dbl(parts[7]),
      currentPrice: _dbl(parts[8]),
      floatingPnl: _dbl(parts[9]),
      margin: _dbl(parts[10]),
      fee: _dbl(parts[11]),
      overnightFee: _dbl(parts[12]),
      timestampSec: int.tryParse(parts[13]) ?? 0,
      leaderId: parts[14],
    );
  }

  static double _dbl(String raw) => double.tryParse(raw.trim()) ?? 0;
}
