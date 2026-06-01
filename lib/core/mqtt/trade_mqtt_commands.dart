import 'package:ap_securities/features/trade/domain/order_execution_type.dart';

/// Builds wire commands published to [TradeMqttConfig.tradePublishTopic].
abstract final class TradeMqttCommands {
  /// `TRADE:symbol:lot:takeProfit:stopLoss:direction` — direction 1 buy, 2 sell.
  static String instantTrade({
    required String symbol,
    required double lot,
    required double? takeProfit,
    required double? stopLoss,
    required bool isBuy,
  }) {
    final lotText = lot.clamp(0.01, double.maxFinite).toStringAsFixed(2);
    final tpText = _priceField(takeProfit);
    final slText = _priceField(stopLoss);
    final direction = isBuy ? '1' : '2';
    return 'TRADE:$symbol:$lotText:$tpText:$slText:$direction';
  }

  /// `ORDER:symbol:lot:price:direction:type:tp:sl:expiryMs`
  static String pendingOrder({
    required String symbol,
    required double lot,
    required double price,
    required OrderExecutionType executionType,
    required double? takeProfit,
    required double? stopLoss,
    required int expiryMs,
  }) {
    final lotText = lot.clamp(0.01, double.maxFinite).toStringAsFixed(2);
    final priceText = _priceField(price);
    final tpText = _priceField(takeProfit);
    final slText = _priceField(stopLoss);
    final direction = executionType.isBuyDirection ? '1' : '2';
    final orderType = '${executionType.mqttPendingOrderType}';
    return 'ORDER:$symbol:$lotText:$priceText:$direction:$orderType:'
        '$tpText:$slText:$expiryMs';
  }

  /// Subscribe open positions for account (`POSITION::{accountId}`).
  static String subscribePositions(String accountId) =>
      'POSITION::$accountId';

  /// `CLOSE_ORDER:orderId:symbol`
  static String closeOrder({
    required String orderId,
    required String symbol,
  }) =>
      'CLOSE_ORDER:$orderId:$symbol';

  /// `ORDER_REMOVE:symbol:uuid`
  static String removePendingOrder({
    required String symbol,
    required String orderId,
  }) =>
      'ORDER_REMOVE:$symbol:$orderId';

  /// `MODIFY_PROFIT_LOSS:orderId:takeProfit:stopLoss` — open position.
  static String modifyProfitLoss({
    required String orderId,
    required double? takeProfit,
    required double? stopLoss,
  }) {
    final tpText = _priceField(takeProfit);
    final slText = _priceField(stopLoss);
    return 'MODIFY_PROFIT_LOSS:$orderId:$tpText:$slText';
  }

  /// `ORDER_MODIFY_PROFIT_LOSS:orderId:takeProfit:stopLoss` — pending order.
  static String orderModifyProfitLoss({
    required String orderId,
    required double? takeProfit,
    required double? stopLoss,
  }) {
    final tpText = _priceField(takeProfit);
    final slText = _priceField(stopLoss);
    return 'ORDER_MODIFY_PROFIT_LOSS:$orderId:$tpText:$slText';
  }

  /// Subscribe account wallet / floating summary pushes.
  static const String subscribeAmountFloating = 'SUBSCRIBE_AMOUNT_FLOATING';

  static String _priceField(double? price) {
    if (price == null || price <= 0) return '0';
    if (price.abs() >= 10) return price.toStringAsFixed(2);
    return price.toStringAsFixed(5);
  }
}
