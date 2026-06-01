import 'package:ap_securities/core/auth/session_expired_host.dart';
import 'package:ap_securities/features/account/providers/account_providers.dart';
import 'package:ap_securities/features/auth/providers/auth_repository_provider.dart';
import 'package:ap_securities/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Registers [SessionExpiredHost.onSessionExpired] to sign out on `-100` / `-101`.
class SessionExpiredBinder extends ConsumerStatefulWidget {
  const SessionExpiredBinder({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SessionExpiredBinder> createState() =>
      _SessionExpiredBinderState();
}

class _SessionExpiredBinderState extends ConsumerState<SessionExpiredBinder> {
  var _handling = false;

  @override
  void initState() {
    super.initState();
    SessionExpiredHost.onSessionExpired = _handleSessionExpired;
  }

  @override
  void dispose() {
    if (identical(SessionExpiredHost.onSessionExpired, _handleSessionExpired)) {
      SessionExpiredHost.onSessionExpired = null;
    }
    super.dispose();
  }

  Future<void> _handleSessionExpired() async {
    if (_handling) return;
    if (ref.read(authNotifierProvider) is! AuthStateSignedIn) return;

    _handling = true;
    try {
      try {
        await ref.read(authRepositoryProvider).logout();
      } on Object {
        // Token already invalid; still clear local session.
      }
      await ref.read(accountSessionProvider.notifier).signOut();
    } finally {
      _handling = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
