import 'package:ap_securities/features/trade/domain/order_execution_type.dart';
import 'package:ap_securities/features/trade/domain/pending_order_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final expiry = DateTime.now().add(const Duration(hours: 2));

  test('buy limit requires price below ask', () {
    final result = PendingOrderValidator.validate(
      executionType: OrderExecutionType.buyLimit,
      lot: 0.01,
      limitPrice: 105.0,
      expiryAt: expiry,
      bid: 100.0,
      ask: 101.0,
    );
    expect(result.isValid, isFalse);
    expect(result.issue, PendingOrderValidationIssue.buyLimitPriceMustBeBelowAsk);

    final ok = PendingOrderValidator.validate(
      executionType: OrderExecutionType.buyLimit,
      lot: 0.01,
      limitPrice: 100.5,
      expiryAt: expiry,
      bid: 100.0,
      ask: 101.0,
    );
    expect(ok.isValid, isTrue);
  });

  test('buy stop requires price above ask', () {
    final bad = PendingOrderValidator.validate(
      executionType: OrderExecutionType.buyStop,
      lot: 0.01,
      limitPrice: 100.0,
      expiryAt: expiry,
      bid: 100.0,
      ask: 101.0,
    );
    expect(bad.issue, PendingOrderValidationIssue.buyStopPriceMustBeAboveAsk);

    final ok = PendingOrderValidator.validate(
      executionType: OrderExecutionType.buyStop,
      lot: 0.01,
      limitPrice: 102.0,
      expiryAt: expiry,
      bid: 100.0,
      ask: 101.0,
    );
    expect(ok.isValid, isTrue);
  });
}
