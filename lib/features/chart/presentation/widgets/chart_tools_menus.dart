import 'package:ap_securities/core/assets/app_svg_icon.dart';
import 'package:ap_securities/features/chart/domain/chart_indicator.dart';
import 'package:ap_securities/features/chart/domain/chart_series_type.dart';
import 'package:ap_securities/features/chart/providers/chart_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Chart type / indicator menus for the chart tab app bar.
abstract final class ChartToolsMenus {
  static const Color _selectedColor = Color(0xFF2D8BFF);

  static Future<void> showSeriesTypeMenu({
    required BuildContext context,
    required AppLocalizations l10n,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, _) {
            final selected = ref.watch(
              chartControllerProvider.select((s) => s.seriesType),
            );
            final onSelect =
                ref.read(chartControllerProvider.notifier).setSeriesType;

            void select(ChartSeriesType type) {
              onSelect(type);
              Navigator.of(sheetContext).pop();
            }

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.chartToolChartType,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  _seriesTile(
                    context,
                    l10n.chartTypeCandles,
                    ChartSeriesType.candles,
                    selected,
                    () => select(ChartSeriesType.candles),
                  ),
                  _seriesTile(
                    context,
                    l10n.chartTypeHollowCandles,
                    ChartSeriesType.hollowCandles,
                    selected,
                    () => select(ChartSeriesType.hollowCandles),
                  ),
                  _seriesTile(
                    context,
                    l10n.chartTypeLine,
                    ChartSeriesType.line,
                    selected,
                    () => select(ChartSeriesType.line),
                  ),
                  _seriesTile(
                    context,
                    l10n.chartTypeArea,
                    ChartSeriesType.area,
                    selected,
                    () => select(ChartSeriesType.area),
                  ),
                  _seriesTile(
                    context,
                    l10n.chartTypeBars,
                    ChartSeriesType.bars,
                    selected,
                    () => select(ChartSeriesType.bars),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> showIndicatorsMenu({
    required BuildContext context,
    required AppLocalizations l10n,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final selected = ref.watch(
              chartControllerProvider.select((s) => s.indicators),
            );
            final onToggle =
                ref.read(chartControllerProvider.notifier).toggleIndicator;

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.chartToolIndicators,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  _indicatorTile(
                    l10n.chartIndicatorMa,
                    ChartIndicator.ma20,
                    selected,
                    onToggle,
                  ),
                  _indicatorTile(
                    l10n.chartIndicatorEma,
                    ChartIndicator.ema12,
                    selected,
                    onToggle,
                  ),
                  _indicatorTile(
                    l10n.chartIndicatorRsi,
                    ChartIndicator.rsi14,
                    selected,
                    onToggle,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _seriesTile(
    BuildContext context,
    String label,
    ChartSeriesType type,
    ChartSeriesType selected,
    VoidCallback onTap,
  ) {
    final isSelected = type == selected;
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: AppSvgIcon.asset(
        type.iconAsset,
        size: 24,
        color: colorScheme.onSurface,
      ),
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check, size: 20, color: _selectedColor)
          : null,
      onTap: onTap,
    );
  }

  static Widget _indicatorTile(
    String label,
    ChartIndicator indicator,
    Set<ChartIndicator> selected,
    void Function(ChartIndicator) onToggle,
  ) {
    return CheckboxListTile(
      value: selected.contains(indicator),
      title: Text(label),
      onChanged: (_) => onToggle(indicator),
    );
  }
}
