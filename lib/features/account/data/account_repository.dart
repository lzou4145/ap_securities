import 'dart:convert';

import 'package:ap_securities/core/device/device_no_service.dart';
import 'package:ap_securities/features/account/domain/stored_account.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kAccountsKey = 'account_session_accounts_v1';
const _kActiveAccountIdKey = 'account_session_active_id_v1';

class AccountRepository {
  AccountRepository(this._prefs, this._deviceNo);

  final SharedPreferences _prefs;
  final DeviceNoService _deviceNo;

  Future<AccountSession> loadSession() async {
    final raw = _prefs.getString(_kAccountsKey);
    final accounts = <StoredAccount>[];
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final item in list) {
        accounts.add(StoredAccount.fromJson(item as Map<String, dynamic>));
      }
    }
    return AccountSession(
      accounts: accounts,
      activeAccountId: _prefs.getString(_kActiveAccountIdKey),
    );
  }

  Future<String> getOrCreateDeviceNo() => _deviceNo.getDeviceNo();

  Future<void> saveSession(AccountSession session) async {
    final encoded =
        jsonEncode(session.accounts.map((e) => e.toJson()).toList());
    await _prefs.setString(_kAccountsKey, encoded);
    final activeId = session.activeAccountId;
    if (activeId == null) {
      await _prefs.remove(_kActiveAccountIdKey);
    } else {
      await _prefs.setString(_kActiveAccountIdKey, activeId);
    }
  }
}
