import 'package:ap_securities/features/trade/data/trade_orders_repository.dart';
import 'package:ap_securities/features/trade/domain/pending_order.dart';
import 'package:ap_securities/providers/active_account_scope.dart';
import 'package:ap_securities/providers/http_clients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tradeOrdersRepositoryProvider = Provider<TradeOrdersRepository>((ref) {
  return TradeOrdersRepository(ref.watch(appApiProvider));
});

final pendOrderListProvider = AsyncNotifierProvider.autoDispose<
    PendOrderListNotifier, List<PendingOrder>>(
  PendOrderListNotifier.new,
);

class PendOrderListNotifier
    extends AutoDisposeAsyncNotifier<List<PendingOrder>> {
  @override
  Future<List<PendingOrder>> build() async {
    ref.watch(activeAccountScopeProvider);
    return ref.read(tradeOrdersRepositoryProvider).fetchPendingOrders();
  }

  void removeById(String orderId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.where((order) => order.id != orderId).toList(),
    );
  }

  /// Reload from API (e.g. after pending order SL/TP modify — no live push).
  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(tradeOrdersRepositoryProvider).fetchPendingOrders(),
    );
  }
}
