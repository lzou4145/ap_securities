import 'package:ap_securities/features/account/domain/stored_account.dart';
import 'package:ap_securities/features/account/providers/account_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class AuthState {
  const AuthState();
}

class AuthStateSignedOut extends AuthState {
  const AuthStateSignedOut();
}

class AuthStateSignedIn extends AuthState {
  const AuthStateSignedIn({
    required this.userLabel,
    required this.accessToken,
    required this.accountId,
  });

  /// Account ID used for display after sign-in.
  final String userLabel;
  final String accessToken;
  final String accountId;
}

AuthState authStateFromSession(AccountSession? session) {
  final active = session?.activeAccount;
  if (active == null) return const AuthStateSignedOut();
  return AuthStateSignedIn(
    userLabel: active.accountId,
    accessToken: active.accessToken,
    accountId: active.id,
  );
}

/// Derived auth state from persisted account session.
final authStateProvider = Provider<AuthState>((ref) {
  final session = ref.watch(accountSessionProvider);
  return session.when(
    data: authStateFromSession,
    loading: () => const AuthStateSignedOut(),
    error: (_, __) => const AuthStateSignedOut(),
  );
});

/// Whether persisted session is still loading (avoid login flash).
///
/// If [authNotifierProvider] is already signed in (e.g. tests override), do not
/// treat session hydration as blocking so redirects run immediately.
final authSessionLoadingProvider = Provider<bool>((ref) {
  if (ref.watch(authNotifierProvider) is AuthStateSignedIn) return false;
  return ref.watch(accountSessionProvider).isLoading;
});

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Single source of truth; do not also `listen` on [accountSessionProvider]
    // and assign `state` — that duplicates updates and can trigger
    // ConcurrentModificationError during Riverpod's dependency walk.
    return ref.watch(authStateProvider);
  }

  Future<bool> signInWithPassword({
    required String account,
    required String password,
    required String loginCode,
    required bool agreedToPrivacy,
  }) async {
    if (!agreedToPrivacy) return false;
    return ref.read(accountSessionProvider.notifier).signInWithPassword(
          account: account,
          password: password,
          loginCode: loginCode,
        );
  }

  Future<bool> addAccount({
    required String account,
    required String password,
  }) {
    return ref.read(accountSessionProvider.notifier).addAccount(
          account: account,
          password: password,
        );
  }

  Future<void> switchAccount(String accountId) {
    return ref.read(accountSessionProvider.notifier).switchToAccount(accountId);
  }

  Future<void> signOut() {
    return ref.read(accountSessionProvider.notifier).signOut();
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
