import 'package:ap_securities/core/assets/app_icons.dart';
import 'package:ap_securities/core/theme/app_fonts.dart';
import 'package:ap_securities/features/market/domain/market_quote.dart';
import 'package:ap_securities/features/market/presentation/widgets/market_page_colors.dart';
import 'package:flutter/material.dart';

/// Minimal watchlist row in edit mode: selection, symbol, drag handle.
class MarketEditRow extends StatelessWidget {
  const MarketEditRow({
    required this.quote,
    required this.index,
    required this.isSelected,
    required this.showDivider,
    required this.onToggleSelected,
    super.key,
  });

  final MarketQuote quote;
  final int index;
  final bool isSelected;
  final bool showDivider;
  final VoidCallback onToggleSelected;

  static const double _iconSize = 22;
  static const double _dragSize = 22;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.white,
          child: InkWell(
            onTap: onToggleSelected,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _SelectionIcon(isSelected: isSelected),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        quote.symbol,
                        style: AppFonts.marketEditWatchlistSymbol(),
                      ),
                    ),
                    ReorderableDragStartListener(
                      index: index,
                      child: Image.asset(
                        AppIcons.icMove,
                        width: _dragSize,
                        height: _dragSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: MarketPageColors.divider,
          ),
      ],
    );
  }
}

class _SelectionIcon extends StatelessWidget {
  const _SelectionIcon({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Image.asset(
        AppIcons.icSelect,
        width: MarketEditRow._iconSize,
        height: MarketEditRow._iconSize,
        fit: BoxFit.contain,
      );
    }
    return Container(
      width: MarketEditRow._iconSize,
      height: MarketEditRow._iconSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: MarketPageColors.circleBorder,
          width: 1.5,
        ),
      ),
    );
  }
}
