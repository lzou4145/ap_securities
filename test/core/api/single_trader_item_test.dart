import 'package:ap_securities/core/api/models/api_models_follow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SingleTraderItem.fromJson reads wallet from wallets_trade', () {
    final item = SingleTraderItem.fromJson({
      'single_account_id': 10001,
      'created_at': '2026-01-01 10:00:00',
      'single_account': {
        'account_id': 10001,
        'account_name': 'Leader_A',
      },
      'wallets_trade': {
        'account_id': 10001,
        'follow_wallets_trade_amount': '5000.00',
        'follow_commission_rate': 10,
      },
    });

    expect(item.singleAccountId, 10001);
    expect(item.singleAccountWalletTrade?.followWalletsTradeAmount, '5000.00');
    expect(item.singleAccountWalletTrade?.followCommissionRate, 10);
  });
}
