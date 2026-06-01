import 'package:ap_securities/features/trade/domain/modify_profit_loss_validation.dart';
import 'package:ap_securities/features/trade/domain/trade_side.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ModifyProfitLossValidator', () {
    test('buy: valid SL below bid and TP above ask', () {
      final result = ModifyProfitLossValidator.validate(
        side: TradeSide.buy,
        bid: 0.56180,
        ask: 0.56187,
        decimalPlace: 5,
        stopLevelPoints: 16,
        stopLoss: 0.56000,
        takeProfit: 0.57000,
      );
      expect(result.isValid, isTrue);
      expect(result.effectiveStopLevelPoints, 16);
    });

    test('buy: invalid SL too close to bid', () {
      final result = ModifyProfitLossValidator.validate(
        side: TradeSide.buy,
        bid: 0.56180,
        ask: 0.56187,
        decimalPlace: 5,
        stopLevelPoints: 16,
        stopLoss: 0.56179,
        takeProfit: null,
      );
      expect(result.isValid, isFalse);
      expect(
        result.issue,
        ModifyProfitLossValidationIssue.buyStopLossMustBeBelowBid,
      );
      expect(result.effectiveStopLevelPoints, 16);
    });

    test('sell: valid SL above ask and TP below bid', () {
      final result = ModifyProfitLossValidator.validate(
        side: TradeSide.sell,
        bid: 0.56180,
        ask: 0.56187,
        decimalPlace: 5,
        stopLevelPoints: 16,
        stopLoss: 0.56300,
        takeProfit: 0.56000,
      );
      expect(result.isValid, isTrue);
    });

    test('sell: invalid TP above bid', () {
      final result = ModifyProfitLossValidator.validate(
        side: TradeSide.sell,
        bid: 0.56180,
        ask: 0.56187,
        decimalPlace: 5,
        stopLevelPoints: 16,
        stopLoss: null,
        takeProfit: 0.56200,
      );
      expect(result.isValid, isFalse);
      expect(
        result.issue,
        ModifyProfitLossValidationIssue.sellTakeProfitMustBeBelowBid,
      );
    });

    test('unset SL/TP (0) is valid', () {
      final result = ModifyProfitLossValidator.validate(
        side: TradeSide.buy,
        bid: 0.56180,
        ask: 0.56187,
        decimalPlace: 5,
        stopLevelPoints: 16,
        stopLoss: 0,
        takeProfit: 0,
      );
      expect(result.isValid, isTrue);
    });
  });
}
