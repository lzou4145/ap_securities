import 'package:ap_securities/core/mqtt/trade_mqtt_response.dart';
import 'package:ap_securities/features/trade/data/trade_orders_repository.dart';
import 'package:ap_securities/features/trade/domain/order_info_query_type.dart';
import 'package:ap_securities/features/trade/domain/pending_order.dart';

/// Resolves [order_id] for the success page when MQTT omits it in the message.
abstract final class TradeOrderSuccessResolver {
  static Future<String?> resolve({
    required TradeMqttResponse response,
    required int orderInfoType,
    required TradeOrdersRepository repository,
    String? symbol,
  }) async {
    final fromMqtt = response.orderId;
    if (fromMqtt != null && fromMqtt.isNotEmpty) {
      return fromMqtt;
    }
    if (!response.isSuccess) return null;

    if (orderInfoType != OrderInfoQueryType.pending) {
      return null;
    }

    await Future<void>.delayed(const Duration(milliseconds: 200));

    final orders = await repository.fetchPendingOrders();
    final candidates = _filterBySymbol(orders, symbol);
    if (candidates.isEmpty) return null;

    candidates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return candidates.first.id;
  }

  static List<PendingOrder> _filterBySymbol(
    List<PendingOrder> orders,
    String? symbol,
  ) {
    if (symbol == null || symbol.isEmpty) return orders;
    return orders.where((o) => o.symbol == symbol).toList();
  }
}
