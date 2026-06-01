import 'package:ap_securities/core/api/models/api_models_notice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseNoticeListPage reads nested data array', () {
    final page = parseNoticeListPage({
      'data': [
        {
          'id': 2,
          'name': '测试test',
          'publish_time': '2026-05-27 07:22:56',
        },
      ],
      'total': 1,
      'last_page': 1,
      'current_page': 1,
      'per_page': 50,
    });

    expect(page.items, hasLength(1));
    expect(page.items.first.id, 2);
    expect(page.items.first.name, '测试test');
    expect(page.items.first.publishTime, '2026-05-27 07:22:56');
    expect(page.lastPage, 1);
  });
}
