import 'package:ap_securities/core/api/models/api_models_account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AccountWalletsTrade.fromJson parses getWalletsTrade payload', () {
    final wallets = AccountWalletsTrade.fromJson({
      'amount': '8028.06000',
      'close_position': '85.46000',
    });

    expect(wallets.amount, '8028.06000');
    expect(wallets.closePosition, '85.46000');
    expect(wallets.toJson(), {
      'amount': '8028.06000',
      'close_position': '85.46000',
    });
  });
}
