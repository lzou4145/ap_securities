import 'package:ap_securities/core/api/models/api_models_auth.dart';
import 'package:ap_securities/features/account/domain/stored_account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('StoredAccount round-trips accountName and walletsTrade', () {
    const account = StoredAccount(
      id: 'local-1',
      accountId: '10001',
      password: 'secret',
      accessToken: 'token-abc',
      accountName: 'Demo',
      mqttAccount: 'mqtt-key-1',
      walletsTrade: WalletsTrade(
        accountId: 10001,
        amount: '1000.00',
        bail: '500.00',
        lever: 100,
      ),
    );

    final restored = StoredAccount.fromJson(account.toJson());

    expect(restored.accountName, 'Demo');
    expect(restored.mqttAccount, 'mqtt-key-1');
    expect(restored.walletsTrade?.amount, '1000.00');
    expect(restored.walletsTrade?.lever, 100);
  });

  test('StoredAccount.fromJson tolerates legacy payloads', () {
    final legacy = StoredAccount.fromJson({
      'id': 'local-1',
      'accountId': '10001',
      'password': 'secret',
      'accessToken': 'token-abc',
    });

    expect(legacy.accountName, isEmpty);
    expect(legacy.mqttAccount, isEmpty);
    expect(legacy.walletsTrade, isNull);
  });
}
