import 'dart:async';

import 'package:ap_securities/core/network/api_exception.dart';
import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/features/personalized_trading/presentation/personalized_trading_colors.dart';
import 'package:ap_securities/features/personalized_trading/presentation/widgets/rank_list_row.dart';
import 'package:ap_securities/features/personalized_trading/providers/personalized_trading_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PersonalizedTradingPage extends ConsumerStatefulWidget {
  const PersonalizedTradingPage({super.key});

  @override
  ConsumerState<PersonalizedTradingPage> createState() =>
      _PersonalizedTradingPageState();
}

class _PersonalizedTradingPageState
    extends ConsumerState<PersonalizedTradingPage> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(leaderboardSearchQueryProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pageAsync = ref.watch(leaderboardRankListProvider);
    final searchQuery = ref.watch(leaderboardSearchQueryProvider).trim();
    final tradingTime = ref.watch(leaderboardTradingTimeProvider);
    final ranking = ref.watch(leaderboardRankingMethodProvider);

    return Scaffold(
      backgroundColor: PersonalizedTradingColors.pageBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PageHeader(
              updatedAt: pageAsync.valueOrNull?.updatedAt,
              onBack: () => context.pop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  _FilterChip(
                    label: _tradingTimeLabel(l10n, tradingTime),
                    onTap: () => _showTradingTimeSheet(context, l10n),
                  ),
                  const SizedBox(width: 20),
                  _FilterChip(
                    label: _rankingLabel(l10n, ranking),
                    onTap: () => _showRankingSheet(context, l10n),
                  ),
                  const Spacer(),
                  _HeaderOutlineButton(
                    label: l10n.followDetailsEntry,
                    onTap: () => context.push(AppRoutes.profileFollowDetails),
                  ),
                  const SizedBox(width: 8),
                  _HeaderPrimaryButton(
                    label: l10n.leaderboardSignalSettings,
                    onTap: () =>
                        context.push(AppRoutes.profileSingleProviderSettings),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                keyboardType: TextInputType.number,
                onChanged: _onSearchChanged,
                onSubmitted: (v) {
                  _searchDebounce?.cancel();
                  ref.read(leaderboardSearchQueryProvider.notifier).state = v;
                },
                style: const TextStyle(
                  fontSize: 15,
                  color: PersonalizedTradingColors.title,
                ),
                decoration: InputDecoration(
                  hintText: l10n.leaderboardSearchHint,
                  hintStyle: const TextStyle(
                    fontSize: 15,
                    color: PersonalizedTradingColors.searchHint,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 22,
                    color: PersonalizedTradingColors.searchHint,
                  ),
                  filled: true,
                  fillColor: PersonalizedTradingColors.searchBg,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: pageAsync.when(
                data: (page) {
                  final ranks = page.ranks;
                  if (ranks.isEmpty) {
                    return Center(
                      child: Text(
                        searchQuery.isNotEmpty
                            ? l10n.leaderboardSearchUserNotFound
                            : l10n.leaderboardEmpty,
                        style: const TextStyle(
                          color: PersonalizedTradingColors.subtitle,
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: PersonalizedTradingColors.primaryBlue,
                    onRefresh: () async {
                      ref.invalidate(leaderboardRankListProvider);
                      await ref.read(leaderboardRankListProvider.future);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: ranks.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: PersonalizedTradingColors.divider,
                      ),
                      itemBuilder: (context, i) => RankListRow(
                        rank: ranks[i],
                        position: i + 1,
                      ),
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) {
                  if (searchQuery.isNotEmpty &&
                      e is ApiException &&
                      e.kind == ApiErrorKind.business) {
                    return Center(
                      child: Text(
                        l10n.leaderboardSearchUserNotFound,
                        style: const TextStyle(
                          color: PersonalizedTradingColors.subtitle,
                        ),
                      ),
                    );
                  }

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.leaderboardLoadFailed,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: PersonalizedTradingColors.subtitle,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () =>
                                ref.invalidate(leaderboardRankListProvider),
                            child: Text(l10n.retryButton),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _tradingTimeLabel(AppLocalizations l10n, String key) => switch (key) {
        '15d' => l10n.leaderboardTime15d,
        '30d' => l10n.leaderboardTime30d,
        _ => l10n.leaderboardTime7d,
      };

  String _rankingLabel(AppLocalizations l10n, String key) => switch (key) {
        'bottom20' => l10n.leaderboardRankBottom20,
        _ => l10n.leaderboardRankTop20,
      };

  void _showTradingTimeSheet(BuildContext context, AppLocalizations l10n) {
    final options = <String, String>{
      '7d': l10n.leaderboardTime7d,
      '15d': l10n.leaderboardTime15d,
      '30d': l10n.leaderboardTime30d,
    };
    _showOptionSheet(
      context,
      title: l10n.leaderboardFilterTradingTime,
      options: options,
      selected: ref.read(leaderboardTradingTimeProvider),
      onSelected: (v) =>
          ref.read(leaderboardTradingTimeProvider.notifier).state = v,
    );
  }

  void _showRankingSheet(BuildContext context, AppLocalizations l10n) {
    final options = <String, String>{
      'top20': l10n.leaderboardRankTop20,
      'bottom20': l10n.leaderboardRankBottom20,
    };
    _showOptionSheet(
      context,
      title: l10n.leaderboardFilterRanking,
      options: options,
      selected: ref.read(leaderboardRankingMethodProvider),
      onSelected: (v) =>
          ref.read(leaderboardRankingMethodProvider.notifier).state = v,
    );
  }

  void _showOptionSheet(
    BuildContext context, {
    required String title,
    required Map<String, String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              for (final entry in options.entries)
                ListTile(
                  title: Text(entry.value),
                  trailing: selected == entry.key
                      ? const Icon(
                          Icons.check,
                          color: PersonalizedTradingColors.primaryBlue,
                        )
                      : null,
                  onTap: () {
                    onSelected(entry.key);
                    Navigator.of(ctx).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.updatedAt,
    required this.onBack,
  });

  final DateTime? updatedAt;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final timeStr = updatedAt != null
        ? DateFormat('yyyy.MM.dd HH:mm:ss', locale).format(updatedAt!)
        : '--';

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: PersonalizedTradingColors.primaryBlue,
            ),
          ),
          Expanded(
            child: Text(
              l10n.leaderboardTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: PersonalizedTradingColors.title,
              ),
            ),
          ),
          Flexible(
            child: Text(
              l10n.leaderboardUpdatedAt(timeStr),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 11,
                color: PersonalizedTradingColors.subtitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: PersonalizedTradingColors.title,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: PersonalizedTradingColors.subtitle,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderOutlineButton extends StatelessWidget {
  const _HeaderOutlineButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: PersonalizedTradingColors.primaryBlue),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: PersonalizedTradingColors.primaryBlue,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderPrimaryButton extends StatelessWidget {
  const _HeaderPrimaryButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PersonalizedTradingColors.primaryBlue,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
