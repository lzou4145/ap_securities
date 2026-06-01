import 'package:ap_securities/core/api/models/api_models_notice.dart';
import 'package:ap_securities/features/announcements/data/announcements_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromListItem maps notice list row', () {
    final item = AnnouncementsMapper.fromListItem(
      const NoticeItem(
        id: 12,
        name: '系统维护通知',
        publishTime: '2026-05-10 18:30:00',
      ),
    );

    expect(item.id, '12');
    expect(item.title, '系统维护通知');
    expect(item.publishedAt, DateTime.parse('2026-05-10T18:30:00'));
    expect(item.body, isEmpty);
  });

  test('fromDetail maps notice content', () {
    final item = AnnouncementsMapper.fromDetail(
      const NoticeDetail(
        id: 3,
        name: '安全提醒',
        content: '请勿泄露密码。',
        publishTime: '2026-05-01 14:15:00',
      ),
    );

    expect(item.id, '3');
    expect(item.title, '安全提醒');
    expect(item.body, '请勿泄露密码。');
    expect(item.publishedAt, DateTime.parse('2026-05-01T14:15:00'));
  });
}
