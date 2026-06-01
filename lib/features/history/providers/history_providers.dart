import 'package:ap_securities/features/history/data/history_period_query.dart';
import 'package:ap_securities/features/history/data/history_repository.dart';
import 'package:ap_securities/features/history/domain/history_period.dart';
import 'package:ap_securities/features/history/domain/trade_history_record.dart';
import 'package:ap_securities/providers/active_account_scope.dart';
import 'package:ap_securities/providers/http_clients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(ref.watch(appApiProvider));
});

final historyPeriodProvider = StateProvider<HistoryPeriod>(
  (ref) => HistoryPeriod.week,
);

/// Set when user picks a range for [HistoryPeriod.custom] (`type=4`).
final historyCustomRangeProvider = StateProvider<HistoryCustomRange?>(
  (ref) => null,
);

final historyPageProvider =
    FutureProvider.autoDispose<HistoryPageData>((ref) async {
  ref.watch(activeAccountScopeProvider);
  final period = ref.watch(historyPeriodProvider);
  final customRange = ref.watch(historyCustomRangeProvider);
  if (period == HistoryPeriod.custom && customRange == null) {
    return HistoryPageData(
      period: period,
      records: const [],
      summary: const HistorySummary(
        profit: 0,
        credit: 0,
        deposit: 0,
        withdrawal: 0,
        balance: 0,
      ),
    );
  }
  final repo = ref.watch(historyRepositoryProvider);
  return repo.fetchHistory(
    period,
    customRange: period == HistoryPeriod.custom ? customRange : null,
  );
});
