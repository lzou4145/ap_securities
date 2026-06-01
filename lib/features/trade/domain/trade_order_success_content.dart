import 'package:ap_securities/core/api/models/api_models_order.dart';
import 'package:ap_securities/features/trade/data/order_info_display.dart';
import 'package:ap_securities/features/trade/presentation/trade_order_colors.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Display model for the order success screen (from API).
class TradeOrderSuccessContent {
  const TradeOrderSuccessContent({
    required this.orderId,
    required this.symbol,
    required this.tradeModeLabel,
    required this.isBuy,
    required this.lot,
    required this.price,
    this.formattedStopLoss,
    this.formattedTakeProfit,
    this.formattedClosePrice,
  });

  final String orderId;
  final String symbol;
  final String tradeModeLabel;
  final bool isBuy;
  final String lot;
  final String price;
  final String? formattedStopLoss;
  final String? formattedTakeProfit;
  final String? formattedClosePrice;

  Color get tradeModeColor =>
      isBuy ? TradeOrderColors.primaryBlue : TradeOrderColors.sellRed;

  factory TradeOrderSuccessContent.fromOrderInfo(
    OrderInfo info,
    AppLocalizations l10n,
  ) {
    return TradeOrderSuccessContent(
      orderId: info.orderId,
      symbol: OrderInfoDisplay.symbol(info),
      tradeModeLabel: OrderInfoDisplay.tradeModeLabel(info, l10n),
      isBuy: info.type == 1,
      lot: OrderInfoDisplay.formattedLot(info),
      price: OrderInfoDisplay.formattedPrice(info),
      formattedStopLoss: OrderInfoDisplay.formattedStopLoss(info),
      formattedTakeProfit: OrderInfoDisplay.formattedTakeProfit(info),
      formattedClosePrice: OrderInfoDisplay.formattedClosePrice(info),
    );
  }

  factory TradeOrderSuccessContent.fromOrderInfoForClose(
    OrderInfo info,
    AppLocalizations l10n,
  ) {
    return TradeOrderSuccessContent(
      orderId: info.orderId,
      symbol: OrderInfoDisplay.symbol(info),
      tradeModeLabel: OrderInfoDisplay.tradeModeLabel(info, l10n),
      isBuy: info.type == 1,
      lot: OrderInfoDisplay.formattedLot(info),
      price: OrderInfoDisplay.formattedBuildPrice(info),
      formattedStopLoss: OrderInfoDisplay.formattedStopLoss(info),
      formattedTakeProfit: OrderInfoDisplay.formattedTakeProfit(info),
      formattedClosePrice: OrderInfoDisplay.formattedClosePrice(info),
    );
  }
}
