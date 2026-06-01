import 'package:ap_securities/core/api/models/api_models_order.dart';
import 'package:ap_securities/features/trade/data/pend_order_mapper.dart';
import 'package:ap_securities/features/trade/domain/pending_order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps pendOrderList API row', () {
    final item = PendOrderItem.fromJson({
      'account_id': 1000028,
      'variety_id': '1',
      'num': 1,
      'pend_price': '1000.00000',
      'amount': '1000.00000',
      'type': 1,
      'status': 1,
      'pend_type': 1,
      'created_at': '2026-03-27 14:49:11',
      'variety': {
        'id': 1,
        'code': 'qqq',
        'name': 'ABCD第一个',
      },
    });

    final order = PendOrderMapper.fromApi(item);
    expect(order.symbol, 'qqq');
    expect(order.kind, PendingOrderKind.buyLimit);
    expect(order.lot, 1);
    expect(order.limitPrice, 1000);
    expect(order.id, contains('1000028'));
  });
}
