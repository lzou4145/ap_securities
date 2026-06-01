import 'package:ap_securities/features/account/providers/account_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Identity of the signed-in trading account for cache invalidation.
///
/// Changes when the active account or its API token changes (switch / add /
/// login), so providers can refetch account-scoped data.
final activeAccountScopeProvider = Provider<String?>((ref) {
  final session = ref.watch(accountSessionProvider).valueOrNull;
  final active = session?.activeAccount;
  if (active == null) return null;
  return '${active.id}:${active.accessToken}';
});
