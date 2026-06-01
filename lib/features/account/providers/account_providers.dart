import 'package:ap_securities/core/api/models/api_models_account.dart';
import 'package:ap_securities/core/api/models/api_models_auth.dart' as api;
import 'package:ap_securities/core/device/device_no_service.dart';
import 'package:ap_securities/features/account/data/account_repository.dart';
import 'package:ap_securities/features/account/domain/stored_account.dart';
import 'package:ap_securities/features/auth/providers/auth_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Injected from [bootstrap] before [runApp]; must not call [SharedPreferences.getInstance] lazily in providers.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError(
    'sharedPreferencesProvider is not initialized. '
    'Pass SharedPreferences via ProviderScope.overrides in main().',
  );
});

final deviceNoServiceProvider = Provider<DeviceNoService>((ref) {
  return DeviceNoService(ref.watch(sharedPreferencesProvider));
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AccountRepository(prefs, ref.watch(deviceNoServiceProvider));
});

final accountSessionProvider =
    AsyncNotifierProvider<AccountSessionNotifier, AccountSession>(
  AccountSessionNotifier.new,
);

class AccountSessionNotifier extends AsyncNotifier<AccountSession> {
  @override
  Future<AccountSession> build() async {
    final repo = ref.watch(accountRepositoryProvider);
    return repo.loadSession();
  }

  AccountRepository _repo() => ref.read(accountRepositoryProvider);

  Future<void> _persist(AccountSession session) async {
    await _repo().saveSession(session);
    state = AsyncData(session);
  }

  String _newId(String accountId) =>
      '${DateTime.now().millisecondsSinceEpoch}_${accountId.hashCode}';

  Future<void> _upsertActiveFromApiSession({
    required api.AuthSession apiSession,
    required String password,
  }) async {
    final accountKey = apiSession.accountId.toString();
    final current = state.value ?? const AccountSession(accounts: []);
    final existing =
        current.accounts.where((a) => a.accountId == accountKey).firstOrNull;

    final mqttAccount = apiSession.redisKey ?? '';

    final updated = existing != null
        ? existing.copyWith(
            password: password,
            accessToken: apiSession.token,
            accountName: apiSession.accountName,
            mqttAccount: mqttAccount,
            walletsTrade: apiSession.walletsTrade,
          )
        : StoredAccount(
            id: _newId(accountKey),
            accountId: accountKey,
            password: password,
            accessToken: apiSession.token,
            accountName: apiSession.accountName,
            mqttAccount: mqttAccount,
            walletsTrade: apiSession.walletsTrade,
          );

    final accounts = [
      for (final a in current.accounts)
        if (a.accountId != accountKey) a,
      updated,
    ];

    await _persist(
      AccountSession(accounts: accounts, activeAccountId: updated.id),
    );
  }

  /// Upserts account, sets active, persists.
  ///
  /// Returns `false` when account or password is empty.
  /// Throws [ApiException] when the server rejects credentials.
  Future<bool> signInWithPassword({
    required String account,
    required String password,
    required String loginCode,
  }) async {
    final accountId = account.trim();
    if (accountId.isEmpty || password.isEmpty || loginCode.trim().isEmpty) {
      return false;
    }

    final apiSession = await ref.read(authRepositoryProvider).loginWithPassword(
          accountId: accountId,
          password: password,
          loginCode: loginCode,
        );

    await _upsertActiveFromApiSession(
      apiSession: apiSession,
      password: password,
    );
    return true;
  }

  /// Binds account on device via API, switches to it, and persists session.
  ///
  /// Returns `false` when account or password is empty.
  /// Throws [ApiException] on server errors.
  Future<bool> addAccount({
    required String account,
    required String password,
  }) async {
    final accountId = account.trim();
    if (accountId.isEmpty || password.isEmpty) return false;

    final apiSession =
        await ref.read(authRepositoryProvider).addAccountOnDevice(
              accountId: accountId,
              password: password,
            );

    await _upsertActiveFromApiSession(
      apiSession: apiSession,
      password: password,
    );
    return true;
  }

  /// Switches account via API and refreshes token / profile fields.
  ///
  /// [localAccountId] is the persisted [StoredAccount.id], not API account_id.
  /// Throws [ApiException] on server errors.
  Future<void> switchToAccount(String localAccountId) async {
    final current = state.value;
    if (current == null) return;
    final target =
        current.accounts.where((a) => a.id == localAccountId).firstOrNull;
    if (target == null || current.activeAccountId == localAccountId) return;

    final apiSession =
        await ref.read(authRepositoryProvider).switchAccountOnDevice(
              accountId: target.accountId,
            );

    await _upsertActiveFromApiSession(
      apiSession: apiSession,
      password: target.password,
    );
  }

  Future<void> signOut() async {
    final current = state.value ?? const AccountSession(accounts: []);
    await _persist(current.copyWith(clearActiveAccountId: true));
  }

  /// Persists [AccountWalletsTrade] on the active account after close.
  Future<void> updateActiveWalletsFromSnapshot(
    AccountWalletsTrade snapshot,
  ) async {
    final current = state.value;
    final active = current?.activeAccount;
    if (current == null || active == null) return;

    final existing = active.walletsTrade;
    final api.WalletsTrade merged = existing != null
        ? existing.withAccountSnapshot(snapshot)
        : api.WalletsTrade(
            accountId: int.tryParse(active.accountId) ?? 0,
            amount: snapshot.amount,
            bail: '0',
            lever: 0,
            closePosition: snapshot.closePosition,
          );

    final updated = active.copyWith(walletsTrade: merged);
    final accounts = [
      for (final a in current.accounts)
        if (a.id == updated.id) updated else a,
    ];
    await _persist(
      AccountSession(
        accounts: accounts,
        activeAccountId: current.activeAccountId,
      ),
    );
  }
}
