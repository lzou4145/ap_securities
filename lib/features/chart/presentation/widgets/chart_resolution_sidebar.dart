import 'package:ap_securities/features/chart/domain/chart_resolution.dart';
import 'package:flutter/material.dart';

/// Left overlay for picking chart resolution (MT4-style).
class ChartResolutionSidebar extends StatelessWidget {
  const ChartResolutionSidebar({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final ChartResolution selected;
  final ValueChanged<ChartResolution> onSelected;

  static const _panelWidth = 88.0;
  static const Color _selectedColor = Color(0xFF017FF7);

  static Color _panelColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xE61C1C1E)
        : const Color(0xF5FFFFFF);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SizedBox(
      width: _panelWidth,
      child: Material(
        color: _panelColor(brightness),
        elevation: brightness == Brightness.light ? 4 : 0,
        shadowColor: Colors.black26,
        child: SafeArea(
          right: false,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              for (final resolution in ChartResolution.values)
                _ResolutionTile(
                  label: resolution.displayLabel,
                  selected: resolution == selected,
                  onTap: () => onSelected(resolution),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResolutionTile extends StatelessWidget {
  const _ResolutionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: selected
                  ? ChartResolutionSidebar._selectedColor
                  : onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill button shown in the chart tab app bar for the active period.
class ChartResolutionNavButton extends StatelessWidget {
  const ChartResolutionNavButton({
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? colorScheme.surfaceContainerHighest;
    final fg = textColor ?? colorScheme.onSurface;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: textColor != null ? Colors.white24 : null,
        highlightColor: textColor != null ? Colors.white12 : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
