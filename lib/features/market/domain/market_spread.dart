import 'package:ap_securities/features/market/domain/market_price_format.dart';

/// Live spread: scaled ask minus scaled bid after [decimalPlace] rounding.
int marketSpreadFromPrices({
  required double bid,
  required double ask,
  required int decimalPlace,
}) {
  final scale = marketPriceScale(decimalPlace);
  final bidUnits = _priceToUnits(bid, scale);
  final askUnits = _priceToUnits(ask, scale);
  return askUnits - bidUnits;
}

int _priceToUnits(double price, int scale) {
  return (price * scale).round();
}
