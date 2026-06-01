import 'package:ap_securities/core/api/models/api_models_order.dart';
import 'package:ap_securities/features/trade/providers/pend_order_providers.dart';
import 'package:ap_securities/providers/active_account_scope.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef TradeOrderInfoQuery = ({String orderId, int type});

final tradeOrderInfoProvider = FutureProvider.autoDispose
    .family<OrderInfo, TradeOrderInfoQuery>((ref, query) async {
  ref.watch(activeAccountScopeProvider);
  return ref.read(tradeOrdersRepositoryProvider).fetchOrderInfo(
        query.orderId,
        type: query.type,
      );
});
