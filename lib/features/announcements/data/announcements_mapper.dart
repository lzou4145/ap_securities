import 'package:ap_securities/core/api/models/api_models_notice.dart';
import 'package:ap_securities/features/announcements/domain/announcement.dart';

abstract final class AnnouncementsMapper {
  static Announcement fromListItem(NoticeItem item) {
    return Announcement(
      id: item.id.toString(),
      title: item.name,
      publishedAt: _parseDateTime(item.publishTime) ?? DateTime.fromMillisecondsSinceEpoch(0),
      summary: '',
      body: '',
    );
  }

  static Announcement fromDetail(NoticeDetail detail) {
    return Announcement(
      id: detail.id.toString(),
      title: detail.name,
      publishedAt: _parseDateTime(detail.publishTime) ??
          _parseDateTime(detail.createdAt) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      summary: '',
      body: detail.content,
    );
  }

  static DateTime? _parseDateTime(String? raw) {
    if (raw == null) return null;
    final text = raw.trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text.replaceFirst(' ', 'T'));
  }
}
