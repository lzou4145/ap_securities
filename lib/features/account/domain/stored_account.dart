import 'package:ap_securities/core/api/models/api_models_auth.dart';

/// A locally persisted trading account.
class StoredAccount {
  const StoredAccount({
    required this.id,
    required this.accountId,
    required this.password,
    required this.accessToken,
    this.accountName = '',
    this.mqttAccount = '',
    this.walletsTrade,
  });

  final String id;
  final String accountId;
  final String password;
  final String accessToken;
  final String accountName;

  /// MQTT trade account key from [AuthSession.redisKey] (`redis_key` in API).
  final String mqttAccount;
  final WalletsTrade? walletsTrade;

  StoredAccount copyWith({
    String? accountId,
    String? password,
    String? accessToken,
    String? accountName,
    String? mqttAccount,
    WalletsTrade? walletsTrade,
    bool clearWalletsTrade = false,
  }) {
    return StoredAccount(
      id: id,
      accountId: accountId ?? this.accountId,
      password: password ?? this.password,
      accessToken: accessToken ?? this.accessToken,
      accountName: accountName ?? this.accountName,
      mqttAccount: mqttAccount ?? this.mqttAccount,
      walletsTrade:
          clearWalletsTrade ? null : (walletsTrade ?? this.walletsTrade),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountId': accountId,
        'password': password,
        'accessToken': accessToken,
        'accountName': accountName,
        'mqttAccount': mqttAccount,
        if (walletsTrade != null) 'walletsTrade': walletsTrade!.toJson(),
      };

  factory StoredAccount.fromJson(Map<String, dynamic> json) {
    final walletsRaw = json['walletsTrade'];
    return StoredAccount(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      password: json['password'] as String,
      accessToken: json['accessToken'] as String,
      accountName: json['accountName'] as String? ?? '',
      mqttAccount: json['mqttAccount'] as String? ?? '',
      walletsTrade: walletsRaw is Map<String, dynamic>
          ? WalletsTrade.fromJson(walletsRaw)
          : null,
    );
  }
}

class AccountSession {
  const AccountSession({
    required this.accounts,
    this.activeAccountId,
  });

  final List<StoredAccount> accounts;
  final String? activeAccountId;

  StoredAccount? get activeAccount {
    final id = activeAccountId;
    if (id == null) return null;
    for (final a in accounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  AccountSession copyWith({
    List<StoredAccount>? accounts,
    String? activeAccountId,
    bool clearActiveAccountId = false,
  }) {
    return AccountSession(
      accounts: accounts ?? this.accounts,
      activeAccountId: clearActiveAccountId
          ? null
          : (activeAccountId ?? this.activeAccountId),
    );
  }
}
