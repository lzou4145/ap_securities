import 'package:ap_securities/core/theme/app_fonts.dart';
import 'package:ap_securities/features/market/domain/market_price_format.dart';
import 'package:ap_securities/features/market/domain/market_quote.dart';
import 'package:ap_securities/features/market/presentation/widgets/market_page_colors.dart';
import 'package:ap_securities/features/market/presentation/widgets/quote_price_text.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';

class MarketQuoteRow extends StatelessWidget {
  const MarketQuoteRow({
    required this.quote,
    required this.showDivider,
    this.onTap,
    super.key,
  });

  final MarketQuote quote;
  final bool showDivider;
  final VoidCallback? onTap;

  static const String _lowHighPlaceholder = '--';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bidLowText = quote.bidLow > 0
        ? formatMarketPrice(quote.bidLow, decimalPlace: quote.decimalPlace)
        : _lowHighPlaceholder;
    final askHighText = quote.askHigh > 0
        ? formatMarketPrice(quote.askHigh, decimalPlace: quote.decimalPlace)
        : _lowHighPlaceholder;
    final bidExtremeLabel = l10n.marketQuoteLowLabel(bidLowText);
    final askExtremeLabel = l10n.marketQuoteHighLabel(askHighText);

    return Column(
      children: [
        Material(
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 11,
                  child: _SymbolColumn(
                    timestamp: quote.updatedAt,
                    symbol: quote.symbol,
                    spreadLabel: l10n.marketSpreadLabel(quote.spread),
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: _PriceColumn(
                    price: quote.bid,
                    decimalPlace: quote.decimalPlace,
                    trend: quote.trend,
                    extremeLabel: bidExtremeLabel,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 9,
                  child: _PriceColumn(
                    price: quote.ask,
                    decimalPlace: quote.decimalPlace,
                    trend: quote.trend,
                    extremeLabel: askExtremeLabel,
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: MarketPageColors.divider,
          ),
      ],
    );
  }
}

class _SymbolColumn extends StatelessWidget {
  const _SymbolColumn({
    required this.timestamp,
    required this.symbol,
    required this.spreadLabel,
  });

  final String timestamp;
  final String symbol;
  final String spreadLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          timestamp,
          style: const TextStyle(
            fontSize: 11,
            height: 1.3,
            color: MarketPageColors.secondaryText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          symbol,
          style: AppFonts.marketWatchlistSymbol(),
        ),
        const SizedBox(height: 2),
        Text(
          spreadLabel,
          style: const TextStyle(
            fontSize: 11,
            height: 1.3,
            color: MarketPageColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

class _PriceColumn extends StatelessWidget {
  const _PriceColumn({
    required this.price,
    required this.decimalPlace,
    required this.trend,
    required this.extremeLabel,
  });

  final double price;
  final int decimalPlace;
  final QuoteTrend trend;
  final String extremeLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          QuotePriceText.watchlist(
            price: price,
            decimalPlace: decimalPlace,
            trend: trend,
          ),
          const SizedBox(height: 4),
          Text(
            extremeLabel,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11,
              height: 1.3,
              color: MarketPageColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
