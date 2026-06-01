import 'package:ap_securities/core/network/api_exception.dart';
import 'package:ap_securities/core/theme/app_fonts.dart';
import 'package:ap_securities/core/ui/app_toast.dart';
import 'package:ap_securities/features/personalized_trading/domain/follow_trader_args.dart';
import 'package:ap_securities/features/personalized_trading/presentation/personalized_trading_colors.dart';
import 'package:ap_securities/features/personalized_trading/presentation/widgets/rank_list_row.dart';
import 'package:ap_securities/features/personalized_trading/providers/personalized_trading_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FollowTraderPage extends ConsumerStatefulWidget {
  const FollowTraderPage({required this.args, super.key});

  final FollowTraderArgs args;

  @override
  ConsumerState<FollowTraderPage> createState() => _FollowTraderPageState();
}

class _FollowTraderPageState extends ConsumerState<FollowTraderPage> {
  static const _minLot = 0.01;
  static const _lotStep = 0.01;

  double _lot = _minLot;
  int _followStatus = 1;
  bool _submitting = false;
  late final TextEditingController _lotController;

  @override
  void initState() {
    super.initState();
    _lotController = TextEditingController(text: _formatLot(_lot));
  }

  @override
  void dispose() {
    _lotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final args = widget.args;
    final profitText = RankListRow.formatDaysAmount(args.daysAmount);
    final balanceText =
        RankListRow.formatBalance(args.followWalletsTradeAmount);
    final commissionText = args.followCommissionRate > 0
        ? '${args.followCommissionRate}%'
        : '--';
    final profitColor = _profitColor(args.daysAmount);

    return Scaffold(
      backgroundColor: PersonalizedTradingColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.followTraderTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: PersonalizedTradingColors.title,
          ),
        ),
        leading: IconButton(
          onPressed: _submitting ? null : () => context.pop(),
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _TraderSummaryCard(
                  name: args.displayName,
                  accountId: args.singleAccountId,
                  profitText: profitText,
                  profitColor: profitColor,
                  profitLabel: l10n.leaderboardMetricProfit,
                  followBalanceLabel: l10n.leaderboardFollowBalance,
                  followBalanceText: balanceText,
                  commissionLabel: l10n.leaderboardCommissionRate,
                  commissionText: commissionText,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.followTraderLotTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: PersonalizedTradingColors.title,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.followTraderLotHint,
                  style: const TextStyle(
                    fontSize: 13,
                    color: PersonalizedTradingColors.subtitle,
                  ),
                ),
                const SizedBox(height: 12),
                _LotStepperCard(
                  controller: _lotController,
                  onDecrease: () => _adjustLot(-_lotStep),
                  onIncrease: () => _adjustLot(_lotStep),
                  onLotSubmitted: _applyLotFromField,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.followTraderModeTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: PersonalizedTradingColors.title,
                  ),
                ),
                const SizedBox(height: 12),
                _FollowModeSelector(
                  followStatus: _followStatus,
                  forwardLabel: l10n.followTraderModeForward,
                  reverseLabel: l10n.followTraderModeReverse,
                  onChanged: (status) => setState(() => _followStatus = status),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _submitting ? null : _onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: PersonalizedTradingColors.primaryBlue,
                    disabledBackgroundColor:
                        PersonalizedTradingColors.primaryBlue.withValues(
                      alpha: 0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.followTraderConfirm,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _adjustLot(double delta) {
    final next = (_lot + delta).clamp(_minLot, 100.0);
    setState(() {
      _lot = next;
      _lotController.text = _formatLot(_lot);
    });
  }

  void _applyLotFromField() {
    final parsed = double.tryParse(_lotController.text.trim());
    if (parsed == null || parsed < _minLot) {
      setState(() {
        _lot = _minLot;
        _lotController.text = _formatLot(_lot);
      });
      return;
    }
    setState(() {
      _lot = parsed.clamp(_minLot, 100.0);
      _lotController.text = _formatLot(_lot);
    });
  }

  Future<void> _onSubmit() async {
    _applyLotFromField();
    if (_lot < _minLot) {
      context.showAppMessage(context.l10n.followTraderLotTooSmall);
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(personalizedTradingRepositoryProvider).setFollow(
            singleAccountId: widget.args.singleAccountId,
            lot: _lot,
            followStatus: _followStatus,
          );
      if (!mounted) return;
      context.showAppMessage(context.l10n.followTraderSuccess);
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      final message = e.message.trim();
      context.showAppMessage(
        message.isNotEmpty ? message : context.l10n.followTraderFailed,
        variant: AppMessageVariant.error,
        duration: AppToast.tradeErrorDuration,
      );
    } on Object {
      if (!mounted) return;
      context.showAppMessage(
        context.l10n.followTraderFailed,
        variant: AppMessageVariant.error,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  static String _formatLot(double lot) => lot.toStringAsFixed(2);

  static Color _profitColor(String raw) {
    final value = double.tryParse(raw.trim());
    if (value == null) return PersonalizedTradingColors.subtitle;
    if (value > 0) return PersonalizedTradingColors.profitUp;
    if (value < 0) return PersonalizedTradingColors.profitDown;
    return PersonalizedTradingColors.subtitle;
  }
}

class _TraderSummaryCard extends StatelessWidget {
  const _TraderSummaryCard({
    required this.name,
    required this.accountId,
    required this.profitText,
    required this.profitColor,
    required this.profitLabel,
    required this.followBalanceLabel,
    required this.followBalanceText,
    required this.commissionLabel,
    required this.commissionText,
  });

  final String name;
  final int accountId;
  final String profitText;
  final Color profitColor;
  final String profitLabel;
  final String followBalanceLabel;
  final String followBalanceText;
  final String commissionLabel;
  final String commissionText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.person_outline,
              size: 40,
              color: PersonalizedTradingColors.primaryBlue,
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
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: PersonalizedTradingColors.title,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.leaderboardAccountId(accountId),
                    style: const TextStyle(
                      fontSize: 13,
                      color: PersonalizedTradingColors.subtitle,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  profitText,
                  style: AppFonts.dinStyle(
                    fontSize: 18,
                    color: profitColor,
                  ),
                ),
                Text(
                  profitLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: PersonalizedTradingColors.subtitle,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryStat(
                label: followBalanceLabel,
                value: followBalanceText,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryStat(
                label: commissionLabel,
                value: commissionText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: PersonalizedTradingColors.subtitle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.dinStyle(
            fontSize: 16,
            color: PersonalizedTradingColors.title,
          ),
        ),
      ],
    );
  }
}

class _LotStepperCard extends StatelessWidget {
  const _LotStepperCard({
    required this.controller,
    required this.onDecrease,
    required this.onIncrease,
    required this.onLotSubmitted,
  });

  static const _buttonSize = 32.0;
  static const _inputWidth = 64.0;

  final TextEditingController controller;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onLotSubmitted;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: PersonalizedTradingColors.searchBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LotIconButton(
              icon: Icons.remove,
              size: _buttonSize,
              onTap: onDecrease,
            ),
            SizedBox(
              width: _inputWidth,
              child: TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                onSubmitted: (_) => onLotSubmitted(),
                onEditingComplete: onLotSubmitted,
                style: AppFonts.dinStyle(
                  fontSize: 17,
                  color: PersonalizedTradingColors.title,
                  height: 1.2,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 6),
                ),
              ),
            ),
            _LotIconButton(
              icon: Icons.add,
              size: _buttonSize,
              onTap: onIncrease,
            ),
          ],
        ),
      ),
    );
  }
}

class _LotIconButton extends StatelessWidget {
  const _LotIconButton({
    required this.icon,
    required this.onTap,
    this.size = 32,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(
          icon,
          size: size * 0.5,
          color: PersonalizedTradingColors.primaryBlue,
        ),
      ),
    );
  }
}

class _FollowModeSelector extends StatelessWidget {
  const _FollowModeSelector({
    required this.followStatus,
    required this.forwardLabel,
    required this.reverseLabel,
    required this.onChanged,
  });

  final int followStatus;
  final String forwardLabel;
  final String reverseLabel;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: PersonalizedTradingColors.searchBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FollowModeOption(
              label: forwardLabel,
              selected: followStatus == 1,
              onTap: () => onChanged(1),
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: PersonalizedTradingColors.divider,
          ),
          Expanded(
            child: _FollowModeOption(
              label: reverseLabel,
              selected: followStatus == 2,
              onTap: () => onChanged(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowModeOption extends StatelessWidget {
  const _FollowModeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(4),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? PersonalizedTradingColors.primaryBlue
                  : PersonalizedTradingColors.subtitle,
            ),
          ),
        ),
      ),
    );
  }
}
