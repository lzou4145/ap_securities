import 'package:ap_securities/core/api/models/api_models_follow.dart';
import 'package:ap_securities/features/personalized_trading/presentation/personalized_trading_colors.dart';
import 'package:ap_securities/features/personalized_trading/presentation/widgets/follow_details_list_tiles.dart';
import 'package:ap_securities/features/personalized_trading/providers/personalized_trading_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FollowDetailsPage extends ConsumerWidget {
  const FollowDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final listAsync = ref.watch(followDetailsFollowingProvider);

    return Scaffold(
      backgroundColor: PersonalizedTradingColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.followDetailsTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: PersonalizedTradingColors.title,
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: PersonalizedTradingColors.primaryBlue,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: PersonalizedTradingColors.divider,
          ),
        ),
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _ErrorBody(
          message: l10n.followTraderFailed,
          retryLabel: l10n.retryButton,
          onRetry: () => ref.invalidate(followDetailsFollowingProvider),
        ),
        data: (items) => _FollowDetailsList(
          items: items,
          emptyText: l10n.followDetailsEmptyFollowing,
        ),
      ),
    );
  }
}

class _FollowDetailsList extends StatelessWidget {
  const _FollowDetailsList({
    required this.items,
    required this.emptyText,
  });

  final List<SingleTraderItem> items;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          style: const TextStyle(
            fontSize: 14,
            color: PersonalizedTradingColors.subtitle,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 68,
        color: PersonalizedTradingColors.divider,
      ),
      itemBuilder: (context, index) => FollowingListTile(item: items[index]),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: PersonalizedTradingColors.subtitle,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}
