import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/features/announcements/domain/announcement.dart';
import 'package:ap_securities/features/announcements/presentation/announcement_page_colors.dart';
import 'package:ap_securities/features/announcements/providers/announcements_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AnnouncementsListPage extends ConsumerWidget {
  const AnnouncementsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(announcementsListProvider);

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
          l10n.announcementsTitle,
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
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(
                l10n.announcementsEmpty,
                style: const TextStyle(color: AnnouncementPageColors.subtitle),
              ),
            );
          }
          return RefreshIndicator(
            color: AnnouncementPageColors.accent,
            onRefresh: () async {
              ref.invalidate(announcementsListProvider);
              await ref.read(announcementsListProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                return _AnnouncementCard(
                  item: items[i],
                  onTap: () => context.push(
                    AppRoutes.profileAnnouncementDetail(items[i].id),
                  ),
                );
              },
            ),
          );
        },
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
                  onPressed: () => ref.invalidate(announcementsListProvider),
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

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.item,
    required this.onTap,
  });

  final Announcement item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateStr = DateFormat(
      'yyyy-MM-dd HH:mm',
      locale,
    ).format(item.publishedAt);

    return Material(
      color: AnnouncementPageColors.cardBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x14000000)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0x142D8BFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.campaign_outlined,
                        size: 20,
                        color: AnnouncementPageColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: AnnouncementPageColors.title,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.summary.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF555555),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.announcementsPublishedOn(dateStr),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AnnouncementPageColors.subtitle,
                        ),
                      ),
                    ),
                    Text(
                      l10n.announcementsReadMore,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AnnouncementPageColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
