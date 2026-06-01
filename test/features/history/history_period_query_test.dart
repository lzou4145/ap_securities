import 'package:ap_securities/features/history/data/history_period_query.dart';
import 'package:ap_securities/features/history/domain/history_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HistoryPeriodQuery', () {
    test('day uses type 1 with yyyy-MM-dd range', () {
      final q = HistoryPeriodQuery.forPeriod(HistoryPeriod.day);
      expect(q.type, '1');
      expect(q.startTime, _todayString());
      expect(q.endTime, _todayString());
    });

    test('week uses type 2 with date strings', () {
      final q = HistoryPeriodQuery.forPeriod(HistoryPeriod.week);
      expect(q.type, '2');
      expect(q.startTime, _matchesDatePattern);
      expect(q.endTime, _todayString());
    });

    test('month uses type 3 from first day of month', () {
      final now = DateTime.now();
      final q = HistoryPeriodQuery.forPeriod(HistoryPeriod.month);
      expect(q.type, '3');
      expect(
        q.startTime,
        '${now.year}-${now.month.toString().padLeft(2, '0')}-01',
      );
      expect(q.endTime, _todayString());
    });

    test('custom uses type 4 with yyyy-MM-dd', () {
      final q = HistoryPeriodQuery.forPeriod(
        HistoryPeriod.custom,
        customRange: HistoryCustomRange(
          start: DateTime(2026, 3, 9),
          end: DateTime(2026, 3, 15),
        ),
      );
      expect(q.type, '4');
      expect(q.startTime, '2026-03-09');
      expect(q.endTime, '2026-03-15');
    });

    test('custom without range throws', () {
      expect(
        () => HistoryPeriodQuery.forPeriod(HistoryPeriod.custom),
        throwsArgumentError,
      );
    });
  });
}

String _todayString() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}

Matcher get _matchesDatePattern =>
    matches(RegExp(r'^\d{4}-\d{2}-\d{2}$'));
