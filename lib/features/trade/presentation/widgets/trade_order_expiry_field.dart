import 'package:ap_securities/features/trade/presentation/trade_order_colors.dart';
import 'package:ap_securities/features/trade/providers/trade_order_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Inline expiry row; expands a scroll-wheel date/time picker below when tapped.
class TradeOrderExpiryField extends ConsumerStatefulWidget {
  const TradeOrderExpiryField({required this.label, super.key});

  final String label;

  @override
  ConsumerState<TradeOrderExpiryField> createState() =>
      _TradeOrderExpiryFieldState();
}

class _TradeOrderExpiryFieldState extends ConsumerState<TradeOrderExpiryField> {
  static const double _pickerHeight = 216;
  bool _expanded = false;

  DateTime _defaultExpiry() {
    final now = DateTime.now();
    return now.add(const Duration(hours: 1));
  }

  DateTime _clampToFutureMinute(DateTime value) {
    final now = DateTime.now();
    final floor = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    ).add(const Duration(minutes: 1));
    final picked = DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
    );
    return picked.isBefore(floor) ? floor : picked;
  }

  static String formatExpiry(BuildContext context, DateTime expiry) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat('yyyy-MM-dd HH:mm', locale).format(expiry);
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  void _onPickerChanged(DateTime value) {
    final clamped = _clampToFutureMinute(value);
    ref.read(orderExpiryAtProvider.notifier).state = clamped;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final expiry = ref.watch(orderExpiryAtProvider);
    final isSet = expiry != null;
    final valueText =
        isSet ? formatExpiry(context, expiry) : l10n.tradeOrderNotSet;
    final pickerInitial = _clampToFutureMinute(expiry ?? _defaultExpiry());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: _toggleExpanded,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: TradeOrderColors.title,
                    ),
                  ),
                ),
                const SizedBox(width: 28),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          valueText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSet ? FontWeight.w600 : FontWeight.w400,
                            color: isSet
                                ? TradeOrderColors.title
                                : TradeOrderColors.fieldHint,
                          ),
                        ),
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: TradeOrderColors.subtitle,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const Divider(height: 1, color: TradeOrderColors.divider),
          ColoredBox(
            color: const Color(0xFFF7F7F8),
            child: SizedBox(
              height: _pickerHeight,
              child: CupertinoDatePicker(
                key: ValueKey<int>(pickerInitial.millisecondsSinceEpoch),
                mode: CupertinoDatePickerMode.dateAndTime,
                minimumDate: DateTime.now(),
                initialDateTime: pickerInitial,
                minuteInterval: 1,
                use24hFormat: true,
                onDateTimeChanged: _onPickerChanged,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
