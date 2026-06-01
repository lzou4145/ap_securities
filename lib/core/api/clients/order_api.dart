import 'package:ap_securities/core/api/api_client_base.dart';
import 'package:ap_securities/core/api/app_api_paths.dart';
import 'package:ap_securities/core/api/models/api_models_common.dart';
import 'package:ap_securities/core/api/models/api_models_order.dart';

/// APP-api / 订单
class OrderApi extends ApiClientBase {
  OrderApi(super.http);

  /// 订单记录列表
  /// `GET /api/order/historyList`
  ///
  /// [type]: 1 日, 2 周, 3 月, 4 自定义。
  /// [startTime]/[endTime]: `yyyy-MM-dd`（如 `2026-03-09`）。
  Future<PaginatedResponse<OrderHistoryItem>> getHistoryList(
      String? type,
      String? startTime,
      String? endTime,
      String? page,
      String? pageSize) async {
    return http.getData(
      AppApiPaths.order_historyList,
      fromJson: parseOrderHistoryPage,
      queryParameters: ApiClientBase.query(<String, dynamic>{
        'type': type,
        'start_time': startTime,
        'end_time': endTime,
        'page': page,
        'page_size': pageSize
      }),
    );
  }

  /// 订单记录统计
  /// `GET /api/order/historyTotal`
  ///
  /// [type]: 1 日, 2 周, 3 月, 4 自定义。
  /// [startTime]/[endTime]: `yyyy-MM-dd`（如 `2026-03-09`）。
  Future<OrderHistoryTotal> getHistoryTotal(
      String? type, String? startTime, String? endTime) async {
    return http.getData(
      AppApiPaths.order_historyTotal,
      fromJson: OrderHistoryTotal.fromJson,
      queryParameters: ApiClientBase.query(<String, dynamic>{
        'type': type,
        'start_time': startTime,
        'end_time': endTime
      }),
    );
  }

  /// 委托订单列表
  /// `GET /api/order/pendOrderList`
  Future<PaginatedResponse<PendOrderItem>> getPendOrderList(
      String? page, String? pageSize, String? type) async {
    return http.getData(
      AppApiPaths.order_pendOrderList,
      fromJson: parsePendOrderPage,
      queryParameters: ApiClientBase.query(
          <String, dynamic>{'page': page, 'page_size': pageSize, 'type': type}),
    );
  }

  /// 按订单号查询订单详情
  /// `GET /api/order/getOrderInfoByOrderId`
  ///
  /// [type]: 1 挂单, 2 立即执行。
  Future<OrderInfo> getOrderInfoByOrderId(
    String orderId, {
    required String type,
  }) async {
    return http.getData(
      AppApiPaths.order_getOrderInfoByOrderId,
      fromJson: OrderInfo.fromJson,
      queryParameters: ApiClientBase.query(<String, dynamic>{
        'order_id': orderId,
        'type': type,
      }),
    );
  }

  /// 资金流水记录列表
  /// `GET /api/order/fundFlowRecords`
  Future<PaginatedResponse<FundFlowRecord>> getFundFlowRecords(String? page,
      String? pageSize, String? startTime, String? endTime) async {
    return http.getData(
      AppApiPaths.order_fundFlowRecords,
      fromJson: parseFundFlowPage,
      queryParameters: ApiClientBase.query(<String, dynamic>{
        'page': page,
        'page_size': pageSize,
        'start_time': startTime,
        'end_time': endTime
      }),
    );
  }
}
