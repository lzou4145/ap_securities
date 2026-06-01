import 'package:ap_securities/core/api/models/api_models_follow.dart';
import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/core/theme/app_fonts.dart';
import 'package:ap_securities/features/personalized_trading/presentation/personalized_trading_colors.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RankListRow extends StatelessWidget {
  const RankListRow({
    required this.rank,
    required this.position,
    super.key,
  });

  final RankItem rank;
  final int position;

  static String formatDaysAmount(String raw) => _formatDaysAmount(raw);

  static String formatBalance(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '--';
    final value = double.tryParse(trimmed);
    if (value == null) return trimmed;
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final metricText = _formatDaysAmount(rank.daysAmount);
    final metricValue = _parseMetric(rank.daysAmount);
    final metricColor = _metricColor(metricValue);
    final accountName = rank.account.accountName.trim();
    final displayName =
        accountName.isNotEmpty ? accountName : '#${rank.accountId}';
    final balanceText = formatBalance(rank.followWalletsTradeAmount);
    final commissionText = rank.followCommissionRate > 0
        ? '${rank.followCommissionRate}%'
        : '--';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _RankBadge(position: position),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PersonalizedTradingColors.title,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.leaderboardAccountId(rank.accountId),
                  style: const TextStyle(
                    fontSize: 12,
                    color: PersonalizedTradingColors.subtitle,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _MetaChip(
                        label: l10n.leaderboardFollowBalance,
                        value: balanceText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetaChip(
                        label: l10n.leaderboardCommissionRate,
                        value: commissionText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                metricText,
                style: AppFonts.dinStyle(
                  fontSize: 15,
                  color: metricColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.leaderboardMetricProfit,
                style: const TextStyle(
                  fontSize: 11,
                  color: PersonalizedTradingColors.subtitle,
                ),
              ),
              const SizedBox(height: 10),
              _FollowButton(
                label: l10n.followTraderAction,
                onPressed: () {
                  context.push(
                    AppRoutes.profileFollowTraderWithAccount(
                      singleAccountId: rank.accountId,
                      accountName: rank.account.accountName,
                      daysAmount: rank.daysAmount,
                      followWalletsTradeAmount: rank.followWalletsTradeAmount,
                      followCommissionRate: rank.followCommissionRate,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  static double? _parseMetric(String raw) {
    final value = double.tryParse(raw.trim());
    if (value != null) return value;
    return null;
  }

  static String _formatDaysAmount(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '--';
    final value = double.tryParse(trimmed);
    if (value == null) return trimmed;
    final abs = value.abs();
    final text = abs >= 1000
        ? value.toStringAsFixed(2)
        : value.toStringAsFixed(abs >= 1 ? 2 : 4);
    if (value > 0) return '+$text';
    return text;
  }

  static Color _metricColor(double? value) {
    if (value == null) return PersonalizedTradingColors.subtitle;
    if (value > 0) return PersonalizedTradingColors.profitUp;
    if (value < 0) return PersonalizedTradingColors.profitDown;
    return PersonalizedTradingColors.subtitle;
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: PersonalizedTradingColors.searchBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: PersonalizedTradingColors.subtitle,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.dinStyle(
              fontSize: 13,
              color: PersonalizedTradingColors.title,
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PersonalizedTradingColors.primaryBlue,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          constraints: const BoxConstraints(minWidth: 52),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.position});

  final int position;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (position) {
      1 => (
          PersonalizedTradingColors.rankGoldBg,
          PersonalizedTradingColors.rankGoldFg,
        ),
      2 => (
          PersonalizedTradingColors.rankSilverBg,
          PersonalizedTradingColors.rankSilverFg,
        ),
      3 => (
          PersonalizedTradingColors.rankBronzeBg,
          PersonalizedTradingColors.rankBronzeFg,
        ),
      _ => (
          PersonalizedTradingColors.rankDefaultBg,
          PersonalizedTradingColors.rankDefaultFg,
        ),
    };

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$position',
        style: TextStyle(
          fontSize: position <= 3 ? 15 : 14,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
