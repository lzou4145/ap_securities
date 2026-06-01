import 'package:ap_securities/features/trade/domain/order_execution_type.dart';
import 'package:ap_securities/features/trade/presentation/trade_order_colors.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Inline expand/collapse execution type picker on the trade order page.
class TradeExecutionTypePicker extends StatefulWidget {
  const TradeExecutionTypePicker({
    required this.executionType,
    required this.onChanged,
    super.key,
  });

  final OrderExecutionType executionType;
  final ValueChanged<OrderExecutionType> onChanged;

  static const double _optionHeight = 44;
  static const double _collapsedHeight = 40;

  static double get _expandedHeight =>
      _optionHeight * OrderExecutionType.values.length;

  @override
  State<TradeExecutionTypePicker> createState() =>
      _TradeExecutionTypePickerState();
}

class _TradeExecutionTypePickerState extends State<TradeExecutionTypePicker> {
  var _expanded = false;

  void _select(OrderExecutionType type) {
    if (type != widget.executionType) {
      widget.onChanged(type);
    }
    setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = widget.executionType;
    final headerColor = selected.isInstant
        ? TradeOrderColors.title
        : selected.accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: _expanded
                ? TradeExecutionTypePicker._expandedHeight
                : TradeExecutionTypePicker._collapsedHeight,
            width: double.infinity,
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (!_expanded)
                    InkWell(
                      onTap: () => setState(() => _expanded = true),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selected.pickerLabel(l10n),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: headerColor,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: TradeOrderColors.subtitle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_expanded)
                    ColoredBox(
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: OrderExecutionType.values
                            .map(
                              (type) => _ExecutionTypeOption(
                                label: type.pickerLabel(l10n),
                                color: type.isInstant
                                    ? TradeOrderColors.title
                                    : type.accentColor,
                                selected: selected == type,
                                onTap: () => _select(type),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: TradeOrderColors.divider),
      ],
    );
  }
}

class _ExecutionTypeOption extends StatelessWidget {
  const _ExecutionTypeOption({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: TradeExecutionTypePicker._optionHeight,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            if (selected)
              const Positioned(
                right: 16,
                child: Icon(
                  Icons.check,
                  size: 20,
                  color: TradeOrderColors.primaryBlue,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
