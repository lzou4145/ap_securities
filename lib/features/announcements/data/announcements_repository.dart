import 'package:ap_securities/core/api/app_api.dart';
import 'package:ap_securities/features/announcements/data/announcements_mapper.dart';
import 'package:ap_securities/features/announcements/domain/announcement.dart';

class AnnouncementsRepository {
  AnnouncementsRepository(this._api);

  final AppApi _api;

  static const _pageSize = '50';

  Future<List<Announcement>> fetchAnnouncements() async {
    final all = <Announcement>[];
    var page = 1;

    while (true) {
      final response = await _api.notice.getNoticeList('$page', _pageSize);
      if (response.items.isEmpty) break;

      all.addAll(response.items.map(AnnouncementsMapper.fromListItem));

      if (page >= response.lastPage) break;
      page++;
    }

    return List<Announcement>.unmodifiable(all);
  }

  Future<Announcement> fetchAnnouncementById(String id) async {
    final detail = await _api.notice.getNoticeContent(id);
    return AnnouncementsMapper.fromDetail(detail);
  }
}
