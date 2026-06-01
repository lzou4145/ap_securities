import 'package:flutter/material.dart';

abstract final class HistoryPageColors {
  /// History list rows — close to screen edges (see design).
  static const double listHorizontalPadding = 12;

  /// Inset for dividers between history list rows.
  static const double listDividerInset = 15;

  /// Segmented period filter track width.
  static const double filterTrackWidth = 220;

  static const Color background = Colors.white;
  static const Color title = Color(0xFF1A1A1A);
  static const Color subtitle = Color(0xFF8E8E93);
  static const Color summaryLabel = Color(0xFF4A4A4A);
  static const Color summaryValue = Color(0xFF676767);
  static const Color divider = Color(0xFFE5E5E5);
  static const Color buyBlue = Color(0xFF017FF7);
  static const Color sellRed = Color(0xFFFF3B30);
  static const Color profitPositive = Color(0xFF017FF7);
  static const Color profitNegative = Color(0xFFFF3B30);

  /// Segmented control track (gray pill behind tabs).
  static const Color segmentTrack = Color(0xFFEFEFF4);

  /// Divider between 月 and 自定义.
  static const Color segmentDivider = Color(0xFFD1D1D6);
}
