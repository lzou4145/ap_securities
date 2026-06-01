import 'package:ap_securities/core/api/app_api.dart';
import 'package:ap_securities/core/api/models/api_models_order.dart';
import 'package:ap_securities/core/network/api_exception.dart';
import 'package:ap_securities/features/trade/data/order_info_fetch_retry.dart';
import 'package:ap_securities/features/trade/data/pend_order_mapper.dart';
import 'package:ap_securities/features/trade/domain/pending_order.dart';

class TradeOrdersRepository {
  TradeOrdersRepository(this._api);

  final AppApi _api;

  Future<List<PendingOrder>> fetchPendingOrders() async {
    final page = await _api.order.getPendOrderList('1', '30', '1');
    return page.items.map(PendOrderMapper.fromApi).toList();
  }

  /// Loads order detail; retries when the row is not persisted yet after MQTT.
  Future<OrderInfo> fetchOrderInfo(
    String orderId, {
    required int type,
  }) async {
    ApiException? lastNotReady;

    for (var attempt = 0; attempt < OrderInfoFetchRetry.maxAttempts; attempt++) {
      if (attempt == 0) {
        await Future<void>.delayed(OrderInfoFetchRetry.initialDelay);
      } else {
        await Future<void>.delayed(OrderInfoFetchRetry.retryInterval);
      }

      try {
        return await _api.order.getOrderInfoByOrderId(
          orderId,
          type: type.toString(),
        );
      } on ApiException catch (e) {
        if (!OrderInfoFetchRetry.isOrderNotReadyError(e)) {
          rethrow;
        }
        lastNotReady = e;
      }
    }

    throw lastNotReady ??
        ApiException(message: 'Order info unavailable', kind: ApiErrorKind.unknown);
  }
}
