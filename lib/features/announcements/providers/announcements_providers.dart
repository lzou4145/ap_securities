import 'package:ap_securities/features/announcements/data/announcements_repository.dart';
import 'package:ap_securities/features/announcements/domain/announcement.dart';
import 'package:ap_securities/providers/active_account_scope.dart';
import 'package:ap_securities/providers/http_clients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final announcementsRepositoryProvider =
    Provider<AnnouncementsRepository>((ref) {
  return AnnouncementsRepository(ref.watch(appApiProvider));
});

final announcementsListProvider =
    FutureProvider<List<Announcement>>((ref) async {
  ref.watch(activeAccountScopeProvider);
  final repo = ref.watch(announcementsRepositoryProvider);
  return repo.fetchAnnouncements();
});

final announcementDetailProvider =
    FutureProvider.autoDispose.family<Announcement, String>((ref, id) async {
  ref.watch(activeAccountScopeProvider);
  final repo = ref.watch(announcementsRepositoryProvider);
  return repo.fetchAnnouncementById(id);
});
