import 'package:ap_securities/features/trade/domain/trade_side.dart';
import 'package:ap_securities/features/trade/presentation/trade_order_colors.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Order placement mode on the trade order screen.
enum OrderExecutionType {
  /// Market-style — fill at current bid/ask immediately.
  instant,

  /// Pending buy when price falls to the limit.
  buyLimit,

  /// Pending sell when price rises to the limit.
  sellLimit,

  /// Pending buy when price breaks above the stop.
  buyStop,

  /// Pending sell when price breaks below the stop.
  sellStop,
}

extension OrderExecutionTypeX on OrderExecutionType {
  bool get isInstant => this == OrderExecutionType.instant;

  bool get showsPriceAndExpiry => !isInstant;

  bool get isBuyDirection =>
      this == OrderExecutionType.buyLimit ||
      this == OrderExecutionType.buyStop;

  bool get isLimitOrder =>
      this == OrderExecutionType.buyLimit ||
      this == OrderExecutionType.sellLimit;

  bool get isStopOrder =>
      this == OrderExecutionType.buyStop ||
      this == OrderExecutionType.sellStop;

  TradeSide get tradeSide =>
      isBuyDirection ? TradeSide.buy : TradeSide.sell;

  /// MQTT pending order type: 1 = limit, 2 = stop.
  int get mqttPendingOrderType => isStopOrder ? 2 : 1;

  Color get accentColor =>
      isBuyDirection ? TradeOrderColors.primaryBlue : TradeOrderColors.sellRed;

  String label(AppLocalizations l10n) => switch (this) {
        OrderExecutionType.instant => l10n.tradeOrderExecutionInstant,
        OrderExecutionType.buyLimit => l10n.tradeOrderExecutionBuyLimit,
        OrderExecutionType.sellLimit => l10n.tradeOrderExecutionSellLimit,
        OrderExecutionType.buyStop => l10n.tradeOrderExecutionBuyStop,
        OrderExecutionType.sellStop => l10n.tradeOrderExecutionSellStop,
      };

  /// Compact label for the inline execution-type picker.
  String pickerLabel(AppLocalizations l10n) => switch (this) {
        OrderExecutionType.instant => l10n.tradeOrderExecutionInstant,
        OrderExecutionType.buyLimit => l10n.tradeOrderExecutionBuyLimitShort,
        OrderExecutionType.sellLimit => l10n.tradeOrderExecutionSellLimitShort,
        OrderExecutionType.buyStop => l10n.tradeOrderExecutionBuyStopShort,
        OrderExecutionType.sellStop => l10n.tradeOrderExecutionSellStopShort,
      };

  /// Short hint shown in the execution-type picker.
  String hint(AppLocalizations l10n) => switch (this) {
        OrderExecutionType.instant => l10n.tradeOrderExecutionInstantHint,
        OrderExecutionType.buyLimit => l10n.tradeOrderExecutionBuyLimitHint,
        OrderExecutionType.sellLimit => l10n.tradeOrderExecutionSellLimitHint,
        OrderExecutionType.buyStop => l10n.tradeOrderExecutionBuyStopHint,
        OrderExecutionType.sellStop => l10n.tradeOrderExecutionSellStopHint,
      };
}
