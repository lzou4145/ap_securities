import 'package:ap_securities/features/market/domain/market_price_format.dart';
import 'package:ap_securities/features/trade/presentation/trade_formatters.dart';

/// Formatters for trade tab list rows (positions / pending orders).
abstract final class TradeListItemFormatters {
  static String timestampFromSeconds(int timestampSec) {
    if (timestampSec <= 0) return '--';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestampSec * 1000);
    final y = dt.year;
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$y.$m.$d $h:$min:$s';
  }

  static String timestampFromApi(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '--';
    final asInt = int.tryParse(trimmed);
    if (asInt != null && asInt > 0) {
      final sec = trimmed.length > 10 ? asInt ~/ 1000 : asInt;
      return timestampFromSeconds(sec);
    }
    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      return timestampFromSeconds(parsed.millisecondsSinceEpoch ~/ 1000);
    }
    return trimmed;
  }

  static String price(double value, int decimalPlace) {
    if (value <= 0) return '--';
    return formatMarketPrice(value, decimalPlace: decimalPlace);
  }

  static String priceRange({
    required double from,
    required double to,
    required int decimalPlace,
  }) {
    return '${price(from, decimalPlace)} → ${price(to, decimalPlace)}';
  }

  /// Stop/take-profit: zero means not set.
  static String optionalPrice(double value, int decimalPlace) {
    if (value <= 0) return '-';
    return price(value, decimalPlace);
  }

  static String money(double value) {
    if (value == 0) return '0.00';
    return TradeFormatters.amount(value);
  }

  static String optionalMoney(double value) {
    if (value == 0) return '0.00';
    return TradeFormatters.amount(value);
  }
}
