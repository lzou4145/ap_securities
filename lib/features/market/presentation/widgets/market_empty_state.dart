import 'package:ap_securities/features/market/presentation/widgets/market_page_colors.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';

class MarketEmptyState extends StatelessWidget {
  const MarketEmptyState({
    required this.onAddTap,
    super.key,
  });

  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        const Spacer(flex: 3),
        Icon(
          Icons.candlestick_chart_outlined,
          size: 96,
          color: MarketPageColors.secondaryText.withValues(alpha: 0.45),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.marketWatchlistEmpty,
          style: const TextStyle(
            fontSize: 15,
            color: MarketPageColors.secondaryText,
          ),
        ),
        const Spacer(flex: 4),
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 48),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: onAddTap,
              style: FilledButton.styleFrom(
                backgroundColor: MarketPageColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(l10n.marketEmptyAddWatchlist),
            ),
          ),
        ),
      ],
    );
  }
}
