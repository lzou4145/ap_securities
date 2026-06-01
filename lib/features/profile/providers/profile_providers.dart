import 'package:ap_securities/features/account/providers/account_providers.dart';
import 'package:ap_securities/features/profile/domain/profile_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileSummaryProvider = Provider<ProfileSummary?>((ref) {
  final session = ref.watch(accountSessionProvider).valueOrNull;
  final active = session?.activeAccount;
  if (active == null) return null;

  return ProfileSummary(
    accountName:
        active.accountName.isNotEmpty ? active.accountName : active.accountId,
    accountId: active.accountId,
  );
});
