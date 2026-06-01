/// `type` query for `GET /api/order/getOrderInfoByOrderId`.
abstract final class OrderInfoQueryType {
  /// Pending / limit / stop orders.
  static const int pending = 1;

  /// Instant (market) execution.
  static const int instant = 2;
}
