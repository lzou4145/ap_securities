import 'package:ap_securities/core/theme/app_fonts.dart';
import 'package:ap_securities/features/history/domain/trade_history_record.dart';
import 'package:ap_securities/features/history/presentation/widgets/history_page_colors.dart';
import 'package:ap_securities/features/trade/presentation/trade_formatters.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';

class HistorySummarySection extends StatelessWidget {
  const HistorySummarySection({required this.summary, super.key});

  final HistorySummary summary;

  static const double _rowVerticalPadding = 2;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      color: HistoryPageColors.background,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          _SummaryRow(
            label: l10n.historySummaryProfit,
            value: TradeFormatters.amount(summary.profit),
          ),
          _SummaryRow(
            label: l10n.historySummaryDeposit,
            value: TradeFormatters.amount(summary.deposit),
          ),
          _SummaryRow(
            label: l10n.historySummaryWithdrawal,
            value: TradeFormatters.amount(summary.withdrawal),
          ),
          _SummaryRow(
            label: l10n.historySummaryBalance,
            value: TradeFormatters.amount(summary.balance),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: HistorySummarySection._rowVerticalPadding,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppFonts.historyDetailLabel(),
          ),
          const Spacer(),
          Text(
            value,
            style: AppFonts.historyDetailValue(),
          ),
        ],
      ),
    );
  }
}
