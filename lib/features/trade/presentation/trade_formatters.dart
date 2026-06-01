import 'package:ap_securities/features/market/domain/market_price_format.dart';

/// Display formatting for trade tab amounts (space thousands separator).
abstract final class TradeFormatters {
  static String amount(double value, {int decimals = 2}) {
    final negative = value < 0;
    final abs = value.abs();
    final fixed = abs.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    final formatted = parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
    return negative ? '-$formatted' : formatted;
  }

  static String price(double value) {
    if (value >= 100) return value.toStringAsFixed(2);
    return value.toStringAsFixed(5);
  }

  /// Price with variety [decimalPlace] from the market watchlist.
  static String priceAtPlaces(double value, int decimalPlace) {
    return formatMarketPrice(value, decimalPlace: decimalPlace);
  }

  static String volume(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }
}
