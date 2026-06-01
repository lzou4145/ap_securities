import 'package:ap_securities/features/announcements/presentation/announcement_page_colors.dart';
import 'package:ap_securities/features/announcements/presentation/widgets/announcement_html_content.dart';
import 'package:ap_securities/features/announcements/providers/announcements_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AnnouncementDetailPage extends ConsumerWidget {
  const AnnouncementDetailPage({
    required this.announcementId,
    super.key,
  });

  final String announcementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(announcementDetailProvider(announcementId));

    return Scaffold(
      backgroundColor: AnnouncementPageColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: AnnouncementPageColors.accent,
          ),
        ),
        title: Text(
          l10n.announcementsDetailTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AnnouncementPageColors.title,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AnnouncementPageColors.divider,
          ),
        ),
      ),
      body: async.when(
        data: (item) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Material(
            color: AnnouncementPageColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      color: AnnouncementPageColors.title,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.announcementsPublishedOn(
                      DateFormat(
                        'yyyy-MM-dd HH:mm',
                        Localizations.localeOf(context).toLanguageTag(),
                      ).format(item.publishedAt),
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AnnouncementPageColors.subtitle,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                    height: 1,
                    color: AnnouncementPageColors.divider,
                  ),
                  const SizedBox(height: 20),
                  AnnouncementHtmlContent(html: item.body),
                ],
              ),
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$e', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(announcementDetailProvider(announcementId)),
                  child: Text(l10n.retryButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
