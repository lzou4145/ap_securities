import 'package:ap_securities/core/api/models/api_models_follow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RankItem.fromJson reads days_amount and wallet fields', () {
    final item = RankItem.fromJson({
      'account_id': 10001,
      'days_amount': '1234.56000',
      'follow_wallets_trade_amount': '50000.00',
      'follow_commission_rate': 15,
      'account': {
        'account_id': 10001,
        'account_name': 'Trader_A',
      },
    });

    expect(item.daysAmount, '1234.56000');
    expect(item.followWalletsTradeAmount, '50000.00');
    expect(item.followCommissionRate, 15);
    expect(item.account.accountName, 'Trader_A');
  });

  test('RankItem.fromJson reads wallet from wallets_trade', () {
    final item = RankItem.fromJson({
      'account_id': 1000094,
      'days_amount': '-32011.42',
      'account': {
        'account_id': 1000094,
        'account_name': '222225JJPR5P',
      },
      'wallets_trade': {
        'account_id': 1000094,
        'follow_wallets_trade_amount': '0.00000',
        'follow_commission_rate': 0,
      },
    });

    expect(item.daysAmount, '-32011.42');
    expect(item.followWalletsTradeAmount, '0.00000');
    expect(item.followCommissionRate, 0);
    expect(item.account.accountName, '222225JJPR5P');
  });

  test('RankItem.fromJson falls back to single_account_wallet_trade', () {
    final item = RankItem.fromJson({
      'account_id': 10002,
      'days_amount': '100',
      'account': {
        'account_id': 10002,
        'account_name': 'Trader_B',
      },
      'single_account_wallet_trade': {
        'account_id': 10002,
        'follow_wallets_trade_amount': '8000.00',
        'follow_commission_rate': 20,
      },
    });

    expect(item.followWalletsTradeAmount, '8000.00');
    expect(item.followCommissionRate, 20);
  });
}
