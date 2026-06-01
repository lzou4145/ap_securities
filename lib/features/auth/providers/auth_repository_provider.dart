import 'package:ap_securities/features/account/providers/account_providers.dart';
import 'package:ap_securities/features/auth/data/auth_repository.dart';
import 'package:ap_securities/providers/http_clients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: ref.watch(appApiProvider),
    accountRepository: ref.watch(accountRepositoryProvider),
  );
});
