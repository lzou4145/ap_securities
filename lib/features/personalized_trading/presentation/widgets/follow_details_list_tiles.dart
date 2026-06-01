import 'package:ap_securities/core/api/models/api_models_follow.dart';
import 'package:ap_securities/core/network/api_exception.dart';
import 'package:ap_securities/core/theme/app_fonts.dart';
import 'package:ap_securities/core/ui/app_toast.dart';
import 'package:ap_securities/features/personalized_trading/presentation/personalized_trading_colors.dart';
import 'package:ap_securities/features/personalized_trading/presentation/widgets/follow_details_format.dart';
import 'package:ap_securities/features/personalized_trading/providers/personalized_trading_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FollowingListTile extends ConsumerStatefulWidget {
  const FollowingListTile({required this.item, super.key});

  final SingleTraderItem item;

  @override
  ConsumerState<FollowingListTile> createState() => _FollowingListTileState();
}

class _FollowingListTileState extends ConsumerState<FollowingListTile> {
  var _cancelling = false;

  Future<void> _onCancelFollow() async {
    if (_cancelling) return;

    setState(() => _cancelling = true);
    try {
      await ref.read(personalizedTradingRepositoryProvider).delFollow(
            singleAccountId: widget.item.singleAccountId,
          );
      if (!mounted) return;
      ref.invalidate(followDetailsFollowingProvider);
      context.showAppMessage(context.l10n.followDetailsCancelFollowSuccess);
    } on ApiException catch (e) {
      if (!mounted) return;
      final message = e.message.trim();
      context.showAppMessage(
        message.isNotEmpty ? message : context.l10n.followTraderFailed,
        variant: AppMessageVariant.error,
      );
    } on Object {
      if (!mounted) return;
      context.showAppMessage(
        context.l10n.followTraderFailed,
        variant: AppMessageVariant.error,
      );
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final item = widget.item;
    final wallet = item.singleAccountWalletTrade;
    final name = FollowDetailsFormat.displayName(
      item.singleAccount.accountName,
      item.singleAccountId,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.leaderboard_outlined,
              size: 22,
              color: PersonalizedTradingColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
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
                  l10n.leaderboardAccountId(item.singleAccountId),
                  style: const TextStyle(
                    fontSize: 12,
                    color: PersonalizedTradingColors.subtitle,
                  ),
                ),
                if (wallet != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _MetaChip(
                          label: l10n.leaderboardFollowBalance,
                          value: FollowDetailsFormat.formatBalance(
                            wallet.followWalletsTradeAmount,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MetaChip(
                          label: l10n.leaderboardCommissionRate,
                          value: FollowDetailsFormat.formatCommission(
                            wallet.followCommissionRate,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                _MetaLine(
                  label: l10n.followDetailsFollowSince,
                  value: FollowDetailsFormat.formatTime(item.createdAt, locale),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: _cancelling ? null : _onCancelFollow,
            style: OutlinedButton.styleFrom(
              foregroundColor: PersonalizedTradingColors.sellRed,
              disabledForegroundColor:
                  PersonalizedTradingColors.sellRed.withValues(alpha: 0.5),
              side: const BorderSide(
                color: PersonalizedTradingColors.sellRed,
                width: 1,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: _cancelling
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: PersonalizedTradingColors.sellRed,
                    ),
                  )
                : Text(
                    l10n.followDetailsCancelFollow,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PersonalizedTradingColors.sellRed,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: PersonalizedTradingColors.subtitle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: PersonalizedTradingColors.title,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

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
