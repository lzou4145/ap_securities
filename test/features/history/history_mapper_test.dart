import 'package:ap_securities/core/api/models/api_models_order.dart';
import 'package:ap_securities/features/history/data/history_mapper.dart';
import 'package:ap_securities/features/history/domain/history_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps closed order to trade history record', () {
    const item = OrderHistoryItem(
      orderId: '20260520112348654',
      userId: 73,
      accountId: 1000087,
      varietyId: 132,
      num: '0.07',
      status: 2,
      buildPrice: '77486.20000',
      closePrice: '77532.72000',
      amount: '5424.03000',
      type: 1,
      createdAt: '2026-05-20 11:23:48',
      bail: '10.84000',
      takeProfit: '0.00000',
      stopLoss: '0.00000',
      actType: 1,
      buildFee: '7.00000',
      closeAt: '2026-05-20 12:39:24',
      feeInventory: '0.00000',
      profitLoss: '3.26000',
      variety: OrderHistoryVariety(id: 132, code: 'BTCUSDT', name: 'BTCUSDT'),
    );

    final record = HistoryMapper.fromApi(item);

    expect(record.id, '20260520112348654');
    expect(record.symbol, 'BTCUSDT');
    expect(record.side, TradeSide.buy);
    expect(record.volume, 0.07);
    expect(record.openPrice, closeTo(77486.2, 0.01));
    expect(record.closePrice, closeTo(77532.72, 0.01));
    expect(record.profit, closeTo(3.26, 0.01));
    expect(record.closedAt, DateTime.parse('2026-05-20T12:39:24'));
    expect(record.fee, closeTo(7, 0.01));
    expect(record.overnightFee, 0);
    expect(record.stopLoss, 0);
    expect(record.takeProfit, 0);
  });

  test('type 2 maps to sell', () {
    const item = OrderHistoryItem(
      orderId: '1',
      userId: 1,
      accountId: 1,
      varietyId: 1,
      num: '0.1',
      status: 2,
      buildPrice: '1',
      closePrice: '2',
      amount: '0',
      type: 2,
      createdAt: '',
      bail: '0',
      takeProfit: '0',
      stopLoss: '0',
      actType: 1,
      buildFee: '0',
      closeAt: '2026-05-20 12:00:00',
      feeInventory: '0',
      profitLoss: '-1',
      variety: OrderHistoryVariety(id: 1, code: 'EURUSD', name: 'EURUSD'),
    );

    expect(HistoryMapper.fromApi(item).side, TradeSide.sell);
  });

  test('maps history total API to summary', () {
    const total = OrderHistoryTotal(
      totalRechargeNum: '1000.50',
      totalWithdrawNum: '200.25',
      totalOpenNum: '3',
      totalCloseNum: '5',
      totalProfit: '88.12',
      totalBalance: '888.37',
    );

    final summary = HistoryMapper.summaryFromTotal(total);

    expect(summary.profit, closeTo(88.12, 0.01));
    expect(summary.deposit, closeTo(1000.5, 0.01));
    expect(summary.withdrawal, closeTo(200.25, 0.01));
    expect(summary.balance, closeTo(888.37, 0.01));
  });
}
