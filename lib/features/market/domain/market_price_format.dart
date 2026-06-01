/// Price display and stepping from variety [`decimal_place`].
library;

import 'package:ap_securities/features/market/domain/market_quote.dart';

/// Clamps API decimal places to a safe range for UI and charts.
int normalizeDecimalPlace(int decimalPlace) => decimalPlace.clamp(0, 12);

/// Minimum price tick: 10^-decimalPlace (or 1 when decimalPlace is 0).
double minPriceMoveForDecimalPlace(int decimalPlace) {
  final places = normalizeDecimalPlace(decimalPlace);
  if (places == 0) return 1;
  return 1 / marketPriceScale(places);
}

int marketPriceScale(int decimalPlace) {
  final places = normalizeDecimalPlace(decimalPlace);
  var scale = 1;
  for (var i = 0; i < places; i++) {
    scale *= 10;
  }
  return scale;
}

/// Rounds [value] to [decimalPlace] fractional digits.
double roundMarketPrice(double value, int decimalPlace) {
  if (!value.isFinite) return value;
  final places = normalizeDecimalPlace(decimalPlace);
  if (places == 0) return value.roundToDouble();
  final scale = marketPriceScale(places);
  return (value * scale).round() / scale;
}

/// Formats [value] with exactly [decimalPlace] decimals (no trimming).
String formatMarketPrice(double value, {required int decimalPlace}) {
  if (value.isNaN || value.isInfinite) return '--';
  return value.toStringAsFixed(normalizeDecimalPlace(decimalPlace));
}

/// [decimalPlace] from watchlist for [symbol], else [fallback].
int decimalPlaceForSymbol(
  List<MarketQuote>? quotes,
  String symbol, {
  int fallback = 2,
}) {
  if (quotes == null || symbol.isEmpty) return fallback;
  for (final row in quotes) {
    if (row.symbol == symbol) return row.decimalPlace;
  }
  return fallback;
}
