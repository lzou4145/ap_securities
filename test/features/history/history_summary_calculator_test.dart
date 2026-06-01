import 'package:ap_securities/core/api/models/api_models_order.dart';
import 'package:ap_securities/features/history/data/history_summary_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('aggregates trade rows in period', () {
    final summary = HistorySummaryCalculator.fromOrders([
      _trade(profitLoss: '3.26', bail: '10.84'),
      _trade(profitLoss: '-1.00', bail: '5.00'),
    ]);

    expect(summary.profit, closeTo(2.26, 0.01));
    expect(summary.credit, closeTo(15.84, 0.01));
    expect(summary.deposit, 0);
    expect(summary.withdrawal, 0);
    expect(summary.balance, closeTo(2.26, 0.01));
  });

  test('includes deposit and withdrawal by act_type', () {
    final summary = HistorySummaryCalculator.fromOrders([
      _trade(profitLoss: '10', bail: '1'),
      const OrderHistoryItem(
        orderId: 'd1',
        userId: 1,
        accountId: 1,
        varietyId: 0,
        num: '0',
        status: 1,
        buildPrice: '0',
        closePrice: '0',
        amount: '100',
        type: 1,
        createdAt: '',
        bail: '0',
        takeProfit: '0',
        stopLoss: '0',
        actType: HistorySummaryCalculator.actTypeDeposit,
        buildFee: '0',
        closeAt: '',
        feeInventory: '0',
        profitLoss: '0',
      ),
      const OrderHistoryItem(
        orderId: 'w1',
        userId: 1,
        accountId: 1,
        varietyId: 0,
        num: '0',
        status: 1,
        buildPrice: '0',
        closePrice: '0',
        amount: '40',
        type: 1,
        createdAt: '',
        bail: '0',
        takeProfit: '0',
        stopLoss: '0',
        actType: HistorySummaryCalculator.actTypeWithdrawal,
        buildFee: '0',
        closeAt: '',
        feeInventory: '0',
        profitLoss: '0',
      ),
    ]);

    expect(summary.profit, 10);
    expect(summary.deposit, 100);
    expect(summary.withdrawal, 40);
    expect(summary.balance, 70);
  });
}

OrderHistoryItem _trade({
  required String profitLoss,
  required String bail,
}) {
  return OrderHistoryItem(
    orderId: '1',
    userId: 1,
    accountId: 1,
    varietyId: 1,
    num: '0.1',
    status: 2,
    buildPrice: '1',
    closePrice: '2',
    amount: '100',
    type: 1,
    createdAt: '',
    bail: bail,
    takeProfit: '0',
    stopLoss: '0',
    actType: 1,
    buildFee: '0',
    closeAt: '',
    feeInventory: '0',
    profitLoss: profitLoss,
  );
}
