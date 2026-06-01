import 'package:ap_securities/core/api/api_client_base.dart';
import 'package:ap_securities/core/api/app_api_paths.dart';
import 'package:ap_securities/core/api/models/api_models_common.dart';
import 'package:ap_securities/core/api/models/api_models_notice.dart';

/// APP-api / 通知
class NoticeApi extends ApiClientBase {
  NoticeApi(super.http);

  /// 获取通知列表
  /// `GET /api/service/getNoticeList`
  Future<PaginatedResponse<NoticeItem>> getNoticeList(
    String? page,
    String? pageSize,
  ) async {
    return http.getData(
      AppApiPaths.service_getNoticeList,
      fromJson: parseNoticeListPage,
      queryParameters: ApiClientBase.query(
          <String, dynamic>{'page': page, 'page_size': pageSize}),
    );
  }

  /// 获取通知详情
  /// `GET /api/service/getNoticeContent`
  Future<NoticeDetail> getNoticeContent(String? id) async {
    return http.getData(
      AppApiPaths.service_getNoticeContent,
      fromJson: NoticeDetail.fromJson,
      queryParameters: ApiClientBase.query(<String, dynamic>{'id': id}),
    );
  }
}
