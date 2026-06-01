import 'package:flutter/material.dart';

/// Registered custom font families (`pubspec.yaml` → `flutter.fonts`).
///
/// Add new entries here and under `flutter: fonts:` when introducing more files.
abstract final class AppFonts {
  static const String dinFamily = 'D-DIN';
  static const String barlowCondensedFamily = 'BarlowCondensed';

  /// Trading pair name on the market watchlist.
  static const Color marketSymbolColor = Color(0xFF060606);

  static TextStyle dinStyle({
    required double fontSize,
    Color? color,
    double? height,
    double? letterSpacing,
    FontWeight fontWeight = FontWeight.w800,
  }) {
    return TextStyle(
      fontFamily: dinFamily,
      fontSize: fontSize,
      color: color,
      height: height ?? 1,
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
    );
  }

  static TextStyle barlowCondensedBold({
    required double fontSize,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: barlowCondensedFamily,
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
      color: color,
      height: height ?? 1,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle barlowCondensedSemiBold({
    required double fontSize,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: barlowCondensedFamily,
      fontWeight: FontWeight.w600,
      fontSize: fontSize,
      color: color,
      height: height ?? 1,
      letterSpacing: letterSpacing,
    );
  }

  /// Market list — symbol column (e.g. EURUSD).
  static TextStyle marketWatchlistSymbol() {
    return barlowCondensedBold(
      fontSize: 18,
      color: marketSymbolColor,
      height: 1.2,
      letterSpacing: 0.1,
    );
  }

  /// Market tab edit mode — watchlist row symbol.
  static const Color marketEditSymbolColor = Color(0xFF030104);

  static TextStyle marketEditWatchlistSymbol() {
    return barlowCondensedBold(
      fontSize: 18,
      color: marketEditSymbolColor,
      height: 1.2,
      letterSpacing: 0.1,
    );
  }

  static const double marketWatchlistPriceBaseSize = 18;
  static const double marketWatchlistPriceLargeSize = 24;

  /// Trade order quote bar — tiered price, slightly larger than watchlist.
  static const double tradeOrderTieredPriceBaseSize = 22;
  static const double tradeOrderTieredPriceLargeSize = 28;

  /// Market list — enlarged price digits (D-DIN).
  static TextStyle marketWatchlistPriceLarge(Color color) {
    return tieredPriceLarge(color, fontSize: marketWatchlistPriceLargeSize);
  }

  /// Market list — non-tiered price text (integer, dot, leading digits, superscript).
  static TextStyle marketWatchlistPriceBase(Color color) {
    return tieredPriceBase(color, fontSize: marketWatchlistPriceBaseSize);
  }

  /// Trade order — enlarged tier (D-DIN).
  static TextStyle tradeOrderTieredPriceLarge(Color color) {
    return tieredPriceLarge(color, fontSize: tradeOrderTieredPriceLargeSize);
  }

  /// Trade order — base / superscript tier (D-DIN).
  static TextStyle tradeOrderTieredPriceBase(Color color) {
    return tieredPriceBase(color, fontSize: tradeOrderTieredPriceBaseSize);
  }

  static TextStyle tieredPriceLarge(Color color, {required double fontSize}) {
    return dinStyle(
      fontSize: fontSize,
      color: color,
      letterSpacing: -0.5 * (fontSize / marketWatchlistPriceLargeSize),
    );
  }

  static TextStyle tieredPriceBase(Color color, {required double fontSize}) {
    return dinStyle(
      fontSize: fontSize,
      color: color,
      letterSpacing: -0.2 * (fontSize / marketWatchlistPriceBaseSize),
    );
  }

  // --- Trade order page ---

  /// Order page app bar — symbol title.
  static TextStyle tradeOrderTitle() {
    return barlowCondensedBold(
      fontSize: 24,
      color: tradeSummaryValueColor,
      height: 1.2,
    );
  }

  // --- Trade tab ---

  static const Color tradeSummaryLabelColor = Color(0xFF4A4A4A);
  static const Color tradeSummaryValueColor = Color(0xFF000000);

  /// Trade tab header — total floating P/L.
  static TextStyle tradeTotalProfit({Color color = Colors.white}) {
    return barlowCondensedBold(
      fontSize: 24,
      color: color,
      letterSpacing: 0.5,
    );
  }

  /// Trade tab — summary row label (结余、净值…).
  static TextStyle tradeSummaryLabel() {
    return const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: tradeSummaryLabelColor,
      height: 1.35,
    );
  }

  /// Trade tab — summary row value (D-DIN).
  static TextStyle tradeSummaryValue() {
    return dinStyle(
      fontSize: 18,
      color: tradeSummaryValueColor,
      letterSpacing: 0.1,
    );
  }

  /// Trade list — symbol (EURUSD, …).
  static TextStyle tradeListSymbol() {
    return barlowCondensedBold(
      fontSize: 18,
      color: marketSymbolColor,
      height: 1.35,
    );
  }

  /// Trade list — side + lot / order kind (sell 0.01, buy limit…).
  static TextStyle tradeListSide(Color color) {
    return barlowCondensedBold(
      fontSize: 18,
      color: color,
      height: 1.35,
    );
  }

  /// Trade list — profit / loss amount (D-DIN).
  static TextStyle tradeListProfit(Color color) {
    return dinStyle(
      fontSize: 20,
      color: color,
      letterSpacing: 0.1,
    );
  }

  // --- History tab list ---

  static const Color historyMutedColor = Color(0xFF676767);

  /// History list — symbol (AUDCAD).
  static TextStyle historyListSymbol() {
    return barlowCondensedBold(
      fontSize: 18,
      color: marketSymbolColor,
      height: 1.3,
    );
  }

  /// History list — side + volume (sell 0.01).
  static TextStyle historyListSide(Color color) {
    return barlowCondensedBold(
      fontSize: 18,
      color: color,
      height: 1.3,
    );
  }

  /// History list — closed time (top-right).
  static TextStyle historyListTime() {
    return barlowCondensedSemiBold(
      fontSize: 16,
      color: historyMutedColor,
      height: 1.3,
    );
  }

  /// History list — open → close price line (system default font).
  static TextStyle historyListPriceRange() {
    return const TextStyle(
      fontSize: 15,
      height: 1.3,
      color: historyMutedColor,
    );
  }

  /// History expanded detail — label (止损、库存费…).
  static TextStyle historyDetailLabel() {
    return const TextStyle(
      fontSize: 16,
      height: 1.35,
      color: tradeSummaryLabelColor,
    );
  }

  /// History expanded detail — value (D-DIN).
  static TextStyle historyDetailValue() {
    return dinStyle(
      fontSize: 18,
      color: historyMutedColor,
      letterSpacing: 0.1,
    );
  }
}
