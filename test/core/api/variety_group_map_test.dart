import 'package:ap_securities/core/api/models/api_models_market.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('VarietyGroupMap.fromJson includes unknown category keys', () {
    final groups = VarietyGroupMap.fromJson({
      'metal': [
        {
          'variety_id': 1,
          'sort': 1,
          'variety': {
            'id': 1,
            'code': 'XAUUSD',
            'name': 'Gold',
            'point_diff': 10,
            'point_diff_max': 20,
            'fee_inventory_short': '0',
            'fee_inventory_long': '0',
            'unit': '1',
            'multiplier': 100,
            'undulate_min': '0.01',
            'online_status': 1,
            'bail_hedge': '0',
            'bail_percent': '100',
            'decimal_place': 2,
            'stop_loss_level': 1,
            'type': 1,
          },
        },
      ],
      'forex': [
        {
          'variety_id': 2,
          'sort': 1,
          'variety': {
            'id': 2,
            'code': 'EURUSD',
            'name': 'Euro',
            'point_diff': 5,
            'point_diff_max': 10,
            'fee_inventory_short': '0',
            'fee_inventory_long': '0',
            'unit': '1',
            'multiplier': 100,
            'undulate_min': '0.0001',
            'online_status': 1,
            'bail_hedge': '0',
            'bail_percent': '100',
            'decimal_place': 4,
            'stop_loss_level': 1,
            'type': 2,
          },
        },
      ],
    });

    expect(groups.groups.keys, containsAll(['metal', 'forex']));
    expect(groups.all, hasLength(2));
    expect(groups.group('forex')?.first.variety.code, 'EURUSD');
  });
}
