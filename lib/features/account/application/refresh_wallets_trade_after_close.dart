import 'package:ap_securities/core/api/models/api_models_account.dart';
import 'package:ap_securities/core/api/models/api_models_auth.dart';
import 'package:ap_securities/features/account/providers/account_providers.dart';
import 'package:ap_securities/features/trade/providers/trade_tab_providers.dart';
import 'package:ap_securities/providers/http_clients.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fetches `getWalletsTrade` after a successful close and syncs balance everywhere.
Future<void> refreshWalletsTradeAfterClose(WidgetRef ref) async {
  try {
    final snapshot = await ref.read(appApiProvider).account.getWalletsTrade();
    await ref
        .read(accountSessionProvider.notifier)
        .updateActiveWalletsFromSnapshot(snapshot);
    ref.read(tradeTabProvider.notifier).applyWalletsSnapshot(snapshot);
  } on Object catch (e, st) {
    if (kDebugMode) {
      debugPrint('refreshWalletsTradeAfterClose failed: $e\n$st');
    }
  }
}
