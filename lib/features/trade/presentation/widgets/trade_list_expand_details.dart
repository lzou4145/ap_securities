import 'package:ap_securities/features/trade/presentation/trade_page_colors.dart';
import 'package:flutter/material.dart';

/// Label/value pair in the expanded trade list section (two-column grid).
@immutable
class TradeListDetailEntry {
  const TradeListDetailEntry({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

/// Expanded detail block under a position or pending order row.
class TradeListExpandDetails extends StatelessWidget {
  const TradeListExpandDetails({
    required this.leftColumn,
    required this.rightColumn,
    this.timestamp,
    this.horizontalPadding = 16,
    this.labelStyle,
    this.valueStyle,
    super.key,
  });

  final List<TradeListDetailEntry> leftColumn;
  final List<TradeListDetailEntry> rightColumn;

  /// Open time shown above the detail grid when expanded (no label).
  final String? timestamp;
  final double horizontalPadding;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (timestamp != null) ...[
            Text(
              timestamp!,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                color: TradePageColors.subtitle,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DetailColumn(
                  entries: leftColumn,
                  labelStyle: labelStyle,
                  valueStyle: valueStyle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DetailColumn(
                  entries: rightColumn,
                  labelStyle: labelStyle,
                  valueStyle: valueStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailColumn extends StatelessWidget {
  const _DetailColumn({
    required this.entries,
    this.labelStyle,
    this.valueStyle,
  });

  final List<TradeListDetailEntry> entries;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _DetailLine(
            entry: entries[i],
            labelStyle: labelStyle,
            valueStyle: valueStyle,
          ),
        ],
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.entry,
    this.labelStyle,
    this.valueStyle,
  });

  final TradeListDetailEntry entry;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.label,
          style: labelStyle ??
              const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: TradePageColors.subtitle,
              ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            entry.value,
            textAlign: TextAlign.right,
            style: valueStyle ??
                const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: TradePageColors.title,
                ),
          ),
        ),
      ],
    );
  }
}
