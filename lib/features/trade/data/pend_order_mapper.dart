import 'package:ap_securities/core/api/json/json_read.dart';
import 'package:ap_securities/core/api/models/api_models_order.dart';
import 'package:ap_securities/features/trade/domain/pending_order.dart';

abstract final class PendOrderMapper {
  static PendingOrder fromApi(PendOrderItem item) {
    final map = item.raw;
    final symbol = _symbol(map);
    final direction = _direction(map);
    final orderType = _orderType(map);
    final kind = _kind(direction, orderType);
    final lot = _lot(map);
    final limitPrice = _limitPrice(map);
    final currentPrice = _currentPrice(map, direction, limitPrice);

    return PendingOrder(
      id: _id(map),
      symbol: symbol,
      kind: kind,
      lot: lot,
      limitPrice: limitPrice,
      currentPrice: currentPrice,
      takeProfit: _dbl(map['take_profit'] ?? map['takeProfit']),
      stopLoss: _dbl(map['stop_loss'] ?? map['stopLoss']),
      fee: _dbl(
        map['build_fee'] ?? map['fee'] ?? map['commission'] ?? map['handling_fee'],
      ),
      overnightFee: _dbl(
        map['fee_inventory'] ?? map['overnight_fee'] ?? map['swap'] ?? map['inventory_fee'],
      ),
      tax: _dbl(map['tax'] ?? map['tax_fee'] ?? map['taxes']),
      createdAt: JsonRead.asString(map['created_at'] ?? map['create_time']),
    );
  }

  static String _id(Map<String, dynamic> map) {
    final explicit = JsonRead.asString(
      map['id'] ?? map['order_id'] ?? map['uuid'] ?? map['order_no'],
    );
    if (explicit.isNotEmpty) return explicit;
    final accountId = JsonRead.asString(map['account_id']);
    final varietyId = JsonRead.asString(map['variety_id']);
    final createdAt = JsonRead.asString(map['created_at']);
    return '$accountId-$varietyId-$createdAt';
  }

  static String _symbol(Map<String, dynamic> map) {
    final variety = JsonRead.map(map['variety']);
    return JsonRead.asString(
      variety['code'] ?? variety['symbol'] ?? map['code'] ?? map['symbol'],
    );
  }

  /// API `type`: 1 buy, 2 sell.
  static int _direction(Map<String, dynamic> map) {
    return JsonRead.asInt(
      map['type'] ?? map['direction'] ?? map['buy_sell'] ?? map['side'],
      defaultValue: 1,
    );
  }

  /// API `pend_type`: 1 limit, 2 stop.
  static int _orderType(Map<String, dynamic> map) {
    return JsonRead.asInt(
      map['pend_type'] ?? map['order_type'] ?? map['pending_type'],
      defaultValue: 1,
    );
  }

  static PendingOrderKind _kind(int direction, int orderType) {
    final isBuy = direction == 1;
    final isStop = orderType == 2;
    if (isBuy) {
      return isStop ? PendingOrderKind.buyStop : PendingOrderKind.buyLimit;
    }
    return isStop ? PendingOrderKind.sellStop : PendingOrderKind.sellLimit;
  }

  static double _lot(Map<String, dynamic> map) {
    return _dbl(map['num'] ?? map['lot'] ?? map['volume'] ?? map['hand']);
  }

  static double _limitPrice(Map<String, dynamic> map) {
    return _dbl(
      map['pend_price'] ?? map['price'] ?? map['limit_price'] ?? map['order_price'],
    );
  }

  static double _currentPrice(
    Map<String, dynamic> map,
    int direction,
    double fallback,
  ) {
    final fromApi = _dbl(
      map['new_price'] ??
          map['current_price'] ??
          map['market_price'] ??
          map['now_price'] ??
          map['close_price'],
    );
    if (fromApi > 0) return fromApi;
    final bid = _dbl(map['bid']);
    final ask = _dbl(map['ask']);
    if (direction == 1 && ask > 0) return ask;
    if (direction == 2 && bid > 0) return bid;
    return fallback;
  }

  static double _dbl(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim()) ?? 0;
  }
}
