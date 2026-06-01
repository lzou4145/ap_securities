import 'package:ap_securities/features/account/providers/account_providers.dart';
import 'package:ap_securities/providers/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Listens to auth (and similar) changes so `GoRouter` re-runs redirects.
///
/// Uses [authStateProvider] (not [authNotifierProvider]) so hydration
/// `AsyncLoading` → `AsyncData` still produces a SignedOut → SignedIn edge
/// that triggers a refresh; otherwise cold start / login can stay on `/login`.
final goRouterRefreshProvider = Provider<GoRouterRefreshNotifier>((ref) {
  final notifier = GoRouterRefreshNotifier();
  // Re-run redirect after first frame (session hydration may finish same tick).
  Future.microtask(notifier.notify);
  ref
    ..onDispose(notifier.dispose)
    ..listen(accountSessionProvider, (previous, next) {
      final prevLoading = previous?.isLoading ?? true;
      if (prevLoading != next.isLoading) {
        Future.microtask(notifier.notify);
        return;
      }
      final prevActive = previous?.valueOrNull?.activeAccount?.id;
      final nextActive = next.valueOrNull?.activeAccount?.id;
      if (prevActive != nextActive) {
        Future.microtask(notifier.notify);
      }
    })
    ..listen(authStateProvider, (previous, next) {
      final prevIn = previous is AuthStateSignedIn;
      final nextIn = next is AuthStateSignedIn;
      if (prevIn != nextIn) {
        // Defer so GoRouter does not read providers while Riverpod is still
        // finishing invalidations (avoids ConcurrentModificationError).
        Future.microtask(notifier.notify);
      }
    });
  return notifier;
});

final class GoRouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
