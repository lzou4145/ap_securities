import 'package:ap_securities/core/api/models/api_models_order.dart';
import 'package:ap_securities/features/market/domain/market_price_format.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:ap_securities/features/trade/presentation/trade_order_colors.dart';

abstract final class OrderInfoDisplay {
  static String symbol(OrderInfo info) {
    final variety = info.variety;
    if (variety == null) return '';
    return variety.code.isNotEmpty ? variety.code : variety.name;
  }

  static String formattedPrice(OrderInfo info) {
    final raw = _priceRaw(info);
    final parsed = double.tryParse(raw.trim());
    if (parsed == null) return raw;
    if (parsed == 0) return raw.trim().isEmpty ? '--' : raw;
    return formatMarketPrice(parsed, decimalPlace: 5);
  }

  /// Pending orders use [pend_price]; filled orders use [build_price].
  static String _priceRaw(OrderInfo info) {
    final pend = double.tryParse(info.pendPrice.trim()) ?? 0;
    if (pend > 0) return info.pendPrice;

    final build = double.tryParse(info.buildPrice.trim()) ?? 0;
    if (build > 0) return info.buildPrice;

    final close = double.tryParse(info.closePrice.trim()) ?? 0;
    if (close > 0) return info.closePrice;

    return info.pendPrice.isNotEmpty ? info.pendPrice : info.buildPrice;
  }

  static String formattedLot(OrderInfo info) {
    final parsed = double.tryParse(info.num.trim());
    if (parsed == null) return info.num;
    return parsed.toStringAsFixed(2);
  }

  static String tradeModeLabel(OrderInfo info, AppLocalizations l10n) {
    final pendType = info.pendType;
    if (pendType != null) {
      final isBuy = info.type == 1;
      final isStop = pendType == 2;
      if (isBuy) {
        return isStop ? l10n.tradePendingBuyStop : l10n.tradePendingBuyLimit;
      }
      return isStop ? l10n.tradePendingSellStop : l10n.tradePendingSellLimit;
    }
    return info.type == 2 ? l10n.historyTradeSell : l10n.historyTradeBuy;
  }

  static Color tradeModeColor(OrderInfo info) {
    final isBuy = info.type == 1;
    return isBuy ? TradeOrderColors.primaryBlue : TradeOrderColors.sellRed;
  }

  static String formattedStopLoss(OrderInfo info) => _formatLevel(info.stopLoss);

  static String formattedTakeProfit(OrderInfo info) =>
      _formatLevel(info.takeProfit);

  /// Open / entry price for closed-position success screen.
  static String formattedBuildPrice(OrderInfo info) =>
      _formatLevel(info.buildPrice);

  /// Close price for closed-position success screen.
  static String formattedClosePrice(OrderInfo info) =>
      _formatLevel(info.closePrice);

  static String _formatLevel(String raw) {
    final parsed = double.tryParse(raw.trim());
    if (parsed == null) {
      final trimmed = raw.trim();
      return trimmed.isEmpty ? '0.00000' : trimmed;
    }
    return formatMarketPrice(parsed, decimalPlace: 5);
  }
}
