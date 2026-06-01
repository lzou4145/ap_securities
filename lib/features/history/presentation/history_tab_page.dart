import 'package:ap_securities/features/history/domain/history_period.dart';
import 'package:ap_securities/features/history/presentation/history_custom_range_picker.dart';
import 'package:ap_securities/features/history/presentation/widgets/history_page_colors.dart';
import 'package:ap_securities/features/history/presentation/widgets/history_period_filter.dart';
import 'package:ap_securities/features/history/presentation/widgets/history_summary_section.dart';
import 'package:ap_securities/features/history/presentation/widgets/trade_history_row.dart';
import 'package:ap_securities/features/history/providers/history_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryTabPage extends ConsumerWidget {
  const HistoryTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final period = ref.watch(historyPeriodProvider);
    final customRange = ref.watch(historyCustomRangeProvider);
    final pageAsync = ref.watch(historyPageProvider);

    return Scaffold(
      backgroundColor: HistoryPageColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HistoryPeriodFilter(
              selected: period,
              customRangeLabel:
                  period == HistoryPeriod.custom && customRange != null
                      ? formatHistoryCustomRangeLabel(context, customRange)
                      : null,
              onSelected: (p) async {
                if (p == HistoryPeriod.custom) {
                  final range = await pickHistoryCustomRange(
                    context,
                    initial: ref.read(historyCustomRangeProvider),
                  );
                  if (!context.mounted || range == null) return;
                  ref.read(historyCustomRangeProvider.notifier).state = range;
                  ref.read(historyPeriodProvider.notifier).state =
                      HistoryPeriod.custom;
                  return;
                }
                ref.read(historyPeriodProvider.notifier).state = p;
                ref.read(historyCustomRangeProvider.notifier).state = null;
              },
            ),
            Expanded(
              child: pageAsync.when(
                data: (data) {
                  if (data.records.isEmpty) {
                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              l10n.historyListEmpty,
                              style: const TextStyle(
                                color: HistoryPageColors.subtitle,
                              ),
                            ),
                          ),
                        ),
                        HistorySummarySection(summary: data.summary),
                      ],
                    );
                  }
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ...List.generate(data.records.length, (i) {
                        return TradeHistoryRow(
                          record: data.records[i],
                        );
                      }),
                      HistorySummarySection(summary: data.summary),
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$e', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => ref.invalidate(historyPageProvider),
                        child: Text(l10n.retryButton),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
