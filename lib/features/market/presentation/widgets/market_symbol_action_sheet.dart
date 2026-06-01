import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/features/chart/chart_navigation.dart';
import 'package:ap_securities/features/market/domain/market_quote.dart';
import 'package:ap_securities/features/market/market_symbol_navigation.dart';
import 'package:ap_securities/features/market/presentation/widgets/market_page_colors.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Action sheet when tapping a quote row on the market tab.
Future<void> showMarketSymbolActionSheet(
  BuildContext context,
  WidgetRef ref, {
  required MarketQuote quote,
}) {
  final l10n = context.l10n;
  final symbol = quote.symbol;

  return showDialog<void>(
    context: context,
    barrierColor: Colors.black38,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Text(
                symbol,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: MarketPageColors.title,
                ),
              ),
            ),
            const Divider(
                height: 1, thickness: 1, color: MarketPageColors.divider),
            _ActionTile(
              label: l10n.marketQuoteActionTrade,
              textColor: MarketPageColors.priceDown,
              onTap: () {
                Navigator.of(dialogContext).pop();
                context.go(AppRoutes.tradeOrderWithSymbol(symbol));
              },
            ),
            const Divider(
                height: 1, thickness: 1, color: MarketPageColors.divider),
            _ActionTile(
              label: l10n.marketQuoteActionChart,
              onTap: () {
                Navigator.of(dialogContext).pop();
                openChartTab(context, ref, symbol);
              },
            ),
            const Divider(
                height: 1, thickness: 1, color: MarketPageColors.divider),
            _ActionTile(
              label: l10n.marketQuoteActionDetail,
              onTap: () {
                Navigator.of(dialogContext).pop();
                openTradingSymbolDetail(context, variety: quote.variety);
              },
            ),
            const Divider(
                height: 1, thickness: 1, color: MarketPageColors.divider),
            _ActionTile(
              label: l10n.marketQuoteActionCancel,
              onTap: () => Navigator.of(dialogContext).pop(),
            ),
            const SizedBox(height: 4),
          ],
        ),
      );
    },
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.onTap,
    this.textColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: textColor ?? MarketPageColors.title,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
