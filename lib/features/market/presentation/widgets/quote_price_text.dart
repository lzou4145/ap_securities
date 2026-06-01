import 'package:ap_securities/core/theme/app_fonts.dart';
import 'package:ap_securities/features/market/domain/market_price_format.dart';
import 'package:ap_securities/features/market/domain/market_quote.dart';
import 'package:ap_securities/features/market/presentation/widgets/market_page_colors.dart';
import 'package:flutter/material.dart';

/// Tiered quote price (D-DIN): split rules depend on [decimalPlace].
class QuotePriceText extends StatelessWidget {
  /// Watchlist row — trend-colored tiers at list sizes.
  const QuotePriceText.watchlist({
    required this.price,
    required this.trend,
    required this.decimalPlace,
    super.key,
  })  : color = null,
        baseFontSize = AppFonts.marketWatchlistPriceBaseSize,
        largeFontSize = AppFonts.marketWatchlistPriceLargeSize,
        textAlign = null;

  /// Trade order quote bar — fixed color, larger tiers.
  const QuotePriceText.orderQuote({
    required this.price,
    required this.color,
    required this.decimalPlace,
    this.textAlign,
    super.key,
  })  : trend = null,
        baseFontSize = AppFonts.tradeOrderTieredPriceBaseSize,
        largeFontSize = AppFonts.tradeOrderTieredPriceLargeSize;

  final double price;
  final int decimalPlace;
  final QuoteTrend? trend;
  final Color? color;
  final double baseFontSize;
  final double largeFontSize;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ??
        (trend == QuoteTrend.up
            ? MarketPageColors.priceUp
            : MarketPageColors.priceDown);
    final text = formatQuoteDisplayPrice(price, decimalPlace);
    final parts = parseQuotePriceText(text, decimalPlace: decimalPlace);

    final baseStyle =
        AppFonts.tieredPriceBase(resolvedColor, fontSize: baseFontSize);
    final largeStyle =
        AppFonts.tieredPriceLarge(resolvedColor, fontSize: largeFontSize);
    final hasDecimal = text.contains('.');
    final pipsUseLargeTier = parts.pips.isNotEmpty &&
        hasDecimal &&
        normalizeDecimalPlace(decimalPlace) >= 1;
    final pipetteTop = 3 * (baseFontSize / AppFonts.marketWatchlistPriceBaseSize);
    final prefixBottom = parts.pipette.isEmpty
        ? 0.0
        : 2 * (baseFontSize / AppFonts.marketWatchlistPriceBaseSize);

    Widget content;
    if (parts.pips.isEmpty && parts.pipette.isEmpty) {
      content = Text(parts.prefix, style: baseStyle, textAlign: textAlign);
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (parts.prefix.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: prefixBottom),
              child: Text(parts.prefix, style: baseStyle),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parts.pips,
                style: pipsUseLargeTier ? largeStyle : baseStyle,
              ),
              if (parts.pipette.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 0.5, top: pipetteTop),
                  child: Text(parts.pipette, style: baseStyle),
                ),
            ],
          ),
        ],
      );
    }

    if (textAlign == null) return content;
    return Align(
      alignment: textAlign == TextAlign.center
          ? Alignment.center
          : Alignment.centerRight,
      child: content,
    );
  }
}

/// Formats [price] for the market list using variety [decimalPlace].
@visibleForTesting
String formatQuoteDisplayPrice(double price, int decimalPlace) {
  if (price <= 0) return '--';
  return formatMarketPrice(price, decimalPlace: decimalPlace);
}

/// Splits formatted price into prefix / large / superscript tiers.
///
/// - [decimalPlace] ≤ 2: entire fractional part is large (e.g. `229.58` → `229.` + `58`).
/// - [decimalPlace] ≥ 3: last two fractional digits large, last one superscript.
@visibleForTesting
QuotePriceParts parseQuotePriceText(
  String text, {
  required int decimalPlace,
}) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    return const QuotePriceParts(prefix: '--', pips: '', pipette: '');
  }

  final dot = trimmed.indexOf('.');
  if (dot < 0) {
    return QuotePriceParts(prefix: '', pips: trimmed, pipette: '');
  }

  final beforeDot = trimmed.substring(0, dot + 1);
  final frac = trimmed.substring(dot + 1);
  if (frac.isEmpty) {
    return QuotePriceParts(prefix: beforeDot, pips: '', pipette: '');
  }

  final places = normalizeDecimalPlace(decimalPlace);
  if (places <= 2) {
    return QuotePriceParts(prefix: beforeDot, pips: frac, pipette: '');
  }

  if (frac.length < 3) {
    return QuotePriceParts(prefix: beforeDot, pips: frac, pipette: '');
  }

  return QuotePriceParts(
    prefix: beforeDot + frac.substring(0, frac.length - 3),
    pips: frac.substring(frac.length - 3, frac.length - 1),
    pipette: frac.substring(frac.length - 1),
  );
}

@immutable
class QuotePriceParts {
  const QuotePriceParts({
    required this.prefix,
    required this.pips,
    required this.pipette,
  });

  final String prefix;
  final String pips;
  final String pipette;
}
