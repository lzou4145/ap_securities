import 'package:ap_securities/features/history/domain/history_period.dart';
import 'package:ap_securities/features/history/presentation/widgets/history_page_colors.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// iOS-style segmented period filter (日 / 周 / 月 | 自定义).
class HistoryPeriodFilter extends StatelessWidget {
  const HistoryPeriodFilter({
    required this.selected,
    required this.onSelected,
    this.customRangeLabel,
    super.key,
  });

  final HistoryPeriod selected;
  final ValueChanged<HistoryPeriod> onSelected;
  final String? customRangeLabel;

  static const double _trackHeight = 36;
  static const double _trackRadius = 9;
  static const double _thumbRadius = 7;
  static const double _thumbInset = 2;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      color: HistoryPageColors.background,
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: HistoryPageColors.filterTrackWidth,
            height: _trackHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: HistoryPageColors.segmentTrack,
                borderRadius: BorderRadius.circular(_trackRadius),
              ),
              child: Row(
                children: [
                  _Segment(
                    label: l10n.historyPeriodDay,
                    selected: selected == HistoryPeriod.day,
                    onTap: () => onSelected(HistoryPeriod.day),
                  ),
                  _Segment(
                    label: l10n.historyPeriodWeek,
                    selected: selected == HistoryPeriod.week,
                    onTap: () => onSelected(HistoryPeriod.week),
                  ),
                  _Segment(
                    label: l10n.historyPeriodMonth,
                    selected: selected == HistoryPeriod.month,
                    onTap: () => onSelected(HistoryPeriod.month),
                  ),
                  const _SegmentDivider(),
                  _Segment(
                    label: l10n.historyPeriodCustom,
                    selected: selected == HistoryPeriod.custom,
                    onTap: () => onSelected(HistoryPeriod.custom),
                  ),
                ],
              ),
            ),
          ),
          if (selected == HistoryPeriod.custom &&
              customRangeLabel != null &&
              customRangeLabel!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              customRangeLabel!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: HistoryPageColors.subtitle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SegmentDivider extends StatelessWidget {
  const _SegmentDivider();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 1,
        height: 20,
        color: HistoryPageColors.segmentDivider,
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(HistoryPeriodFilter._thumbInset),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(
              HistoryPeriodFilter._thumbRadius,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: HistoryPageColors.title,
            ),
          ),
        ),
      ),
    );
  }
}
