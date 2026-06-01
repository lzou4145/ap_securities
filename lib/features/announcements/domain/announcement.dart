/// A system or trading notice shown in the announcements list.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.publishedAt,
    required this.summary,
    required this.body,
  });

  final String id;
  final String title;
  final DateTime publishedAt;
  final String summary;
  final String body;
}
