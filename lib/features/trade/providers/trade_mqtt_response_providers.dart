import 'package:ap_securities/core/mqtt/trade_mqtt_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Latest parsed trade MQTT push on `push/{accountId}`.
///
/// Includes [TradeMqttResponseEvent.sequence] so listeners always fire.
final tradeMqttLastResponseProvider =
    StateProvider<TradeMqttResponseEvent?>((ref) => null);

/// Symbol awaiting [TradeMqttOperationType.tradeBack] after instant order.
///
/// Must not be [autoDispose] — only read without watch would reset before push.
final tradeInstantOrderPendingProvider = StateProvider<String?>((ref) => null);

/// Symbol awaiting [TradeMqttOperationType.orderBack] after pending order.
final tradePendingOrderPendingProvider = StateProvider<String?>((ref) => null);

/// Order id awaiting [TradeMqttOperationType.closeOrderBack] after close.
final tradeCloseOrderPendingProvider = StateProvider<String?>((ref) => null);

/// Pending order id awaiting [TradeMqttOperationType.orderRemoveBack].
final tradeRemoveOrderPendingProvider = StateProvider<String?>((ref) => null);

class TradeMqttResponseEvent {
  const TradeMqttResponseEvent({
    required this.response,
    required this.sequence,
  });

  final TradeMqttResponse response;
  final int sequence;
}
