import 'package:ap_securities/core/mqtt/position_floating_parser.dart';
import 'package:ap_securities/features/trade/domain/trade_side.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses POSITION_FLOATING_BACK payload', () {
    const payload =
        'POSITION_FLOATING_BACK|1000084:XAUUSD:20260520093623839:1:1:0:0:'
        '4482.67:4481.85:-82:896.53:100:0:1779269783:0';

    final update = PositionFloatingParser.tryParsePayload(payload);
    expect(update, isNotNull);
    expect(update!.accountId, '1000084');
    expect(update.symbol, 'XAUUSD');
    expect(update.orderId, '20260520093623839');
    expect(update.side, TradeSide.buy);
    expect(update.lot, 1);
    expect(update.openPrice, 4482.67);
    expect(update.currentPrice, 4481.85);
    expect(update.floatingPnl, -82);
    final position = update.toOpenPosition();
    expect(position.profit, -82);
    expect(position.fee, 100);
    expect(position.overnightFee, 0);
    expect(position.timestampSec, 1779269783);
    expect(update.leaderId, '0');
    expect(position.leaderId, '0');
    expect(position.isFollowPosition, isFalse);
  });
}
