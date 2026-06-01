import 'package:ap_securities/features/history/data/history_period_query.dart';
import 'package:ap_securities/features/history/presentation/widgets/history_page_colors.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Opens the system date-range picker for history `type=4`.
Future<HistoryCustomRange?> pickHistoryCustomRange(
  BuildContext context, {
  HistoryCustomRange? initial,
}) async {
  final l10n = context.l10n;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final picked = await showDateRangePicker(
    context: context,
    helpText: l10n.historyCustomRangeTitle,
    cancelText: l10n.historyCustomRangeCancel,
    confirmText: l10n.historyCustomRangeConfirm,
    saveText: l10n.historyCustomRangeConfirm,
    fieldStartLabelText: l10n.historyCustomRangeStartLabel,
    fieldEndLabelText: l10n.historyCustomRangeEndLabel,
    firstDate: DateTime(2020),
    lastDate: today,
    initialDateRange: initial?.toDateTimeRange() ??
        DateTimeRange(
          start: today.subtract(const Duration(days: 6)),
          end: today,
        ),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: HistoryPageColors.buyBlue,
              ),
        ),
        child: child ?? const SizedBox.shrink(),
      );
    },
  );

  if (picked == null) return null;
  return HistoryCustomRange.fromDateRange(picked);
}

String formatHistoryCustomRangeLabel(
  BuildContext context,
  HistoryCustomRange range,
) {
  final locale = Localizations.localeOf(context).toString();
  final fmt = DateFormat('yyyy-MM-dd', locale);
  return '${fmt.format(range.start)} — ${fmt.format(range.end)}';
}
