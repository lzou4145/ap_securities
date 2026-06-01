import 'package:ap_securities/features/history/domain/history_period.dart';
import 'package:flutter/material.dart';

/// Custom date range for history API `type=4`.
class HistoryCustomRange {
  const HistoryCustomRange({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;

  DateTimeRange toDateTimeRange() => DateTimeRange(start: start, end: end);

  /// Calendar days for [start] and [end] (end keeps selected day, not 23:59).
  factory HistoryCustomRange.fromDateRange(DateTimeRange range) {
    final start = DateTime(
      range.start.year,
      range.start.month,
      range.start.day,
    );
    final end = DateTime(
      range.end.year,
      range.end.month,
      range.end.day,
    );
    return HistoryCustomRange(start: start, end: end);
  }
}

/// Query parameters for `/api/order/historyList` and `historyTotal`.
///
/// API `type`: 1 day, 2 week, 3 month, 4 custom.
/// `start_time` / `end_time`: `yyyy-MM-dd` (e.g. `2026-03-09`).
class HistoryPeriodQuery {
  const HistoryPeriodQuery({
    required this.type,
    required this.startTime,
    required this.endTime,
  });

  final String type;
  final String startTime;
  final String endTime;

  /// Maps UI period filter to API query.
  static HistoryPeriodQuery forPeriod(
    HistoryPeriod period, {
    HistoryCustomRange? customRange,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final String apiType;
    final DateTime start;
    final DateTime end;

    switch (period) {
      case HistoryPeriod.day:
        apiType = '1';
        start = today;
        end = today;
      case HistoryPeriod.week:
        apiType = '2';
        start = today.subtract(const Duration(days: 7));
        end = today;
      case HistoryPeriod.month:
        apiType = '3';
        start = DateTime(now.year, now.month, 1);
        end = today;
      case HistoryPeriod.custom:
        apiType = '4';
        if (customRange == null) {
          throw ArgumentError(
            'Custom history range is required when type=4',
          );
        }
        start = customRange.start;
        end = customRange.end;
    }

    return HistoryPeriodQuery(
      type: apiType,
      startTime: _dateString(start),
      endTime: _dateString(end),
    );
  }

  static String _dateString(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
