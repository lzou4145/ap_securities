import 'package:ap_securities/core/api/json/json_read.dart';
import 'package:ap_securities/core/api/models/api_models_common.dart';

class NoticeItem {
  const NoticeItem({
    required this.id,
    required this.name,
    this.publishTime,
    this.status,
  });

  factory NoticeItem.fromJson(Map<String, dynamic> json) {
    return NoticeItem(
      id: JsonRead.asInt(json['id']),
      name: JsonRead.asString(json['name']),
      publishTime: JsonRead.asStringOrNull(json['publish_time']),
      status: JsonRead.asIntOrNull(json['status']),
    );
  }

  final int id;
  final String name;
  final String? publishTime;
  final int? status;
}

class NoticeDetail {
  const NoticeDetail({
    required this.id,
    required this.name,
    required this.content,
    this.status,
    this.publishTime,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory NoticeDetail.fromJson(Object? json) {
    final map = JsonRead.map(json);
    return NoticeDetail(
      id: JsonRead.asInt(map['id']),
      name: JsonRead.asString(map['name']),
      content: JsonRead.asString(map['content']),
      status: JsonRead.asIntOrNull(map['status']),
      publishTime: JsonRead.asStringOrNull(map['publish_time']),
      createdAt: JsonRead.asStringOrNull(map['created_at']),
      updatedAt: JsonRead.asStringOrNull(map['updated_at']),
      deletedAt: JsonRead.asStringOrNull(map['deleted_at']),
    );
  }

  final int id;
  final String name;
  final String content;
  final int? status;
  final String? publishTime;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
}

PaginatedResponse<NoticeItem> parseNoticeListPage(Object? json) =>
    PaginatedResponse.fromJson(json, NoticeItem.fromJson);
