import 'dart:async';

import 'package:ap_securities/core/mqtt/trade_mqtt_response.dart';
import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/core/ui/app_toast.dart';
import 'package:ap_securities/features/account/application/refresh_wallets_trade_after_close.dart';
import 'package:ap_securities/features/trade/application/instant_trade_action.dart';
import 'package:ap_securities/features/trade/data/trade_order_success_resolver.dart';
import 'package:ap_securities/features/trade/domain/order_info_query_type.dart';
import 'package:ap_securities/features/trade/domain/trade_order_success_variant.dart';
import 'package:ap_securities/features/trade/providers/pend_order_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void openTradeOrderSuccessPage(
  BuildContext context, {
  required String orderId,
  required int infoType,
  TradeOrderSuccessVariant variant = TradeOrderSuccessVariant.place,
}) {
  context.push(
    AppRoutes.tradeOrderSuccessWithOrderId(
      orderId,
      type: infoType,
      variant: variant.queryValue,
    ),
  );
}

/// Navigates to close-position success page on MQTT success; toast on failure.
Future<void> handleCloseOrderMqttResponse({
  required WidgetRef ref,
  required BuildContext context,
  required AppLocalizations l10n,
  required TradeMqttResponse response,
  required String orderId,
  required VoidCallback onSuccessCleanup,
}) async {
  if (!context.mounted) return;

  if (response.isSuccess) {
    if (!context.mounted) return;
    // Navigate first — clearing modify before this makes the order page flash
    // the normal placement UI for one frame during the route transition.
    context.pushReplacement(
      AppRoutes.tradeOrderSuccessWithOrderId(
        orderId,
        type: OrderInfoQueryType.instant,
        variant: TradeOrderSuccessVariant.close.queryValue,
      ),
    );
    onSuccessCleanup();
    unawaited(refreshWalletsTradeAfterClose(ref));
    return;
  }

  context.showAppMessage(
    tradeResultMessage(l10n, response),
    variant: AppMessageVariant.error,
    duration: AppToast.tradeErrorDuration,
  );
}

/// Navigates to modify SL/TP success page on MQTT success; toast on failure.
Future<void> handleModifyProfitLossMqttResponse({
  required WidgetRef ref,
  required BuildContext context,
  required AppLocalizations l10n,
  required TradeMqttResponse response,
  required String orderId,
  required int orderInfoType,
  required VoidCallback onSuccessCleanup,
}) async {
  if (!context.mounted) return;

  if (response.isSuccess) {
    if (!context.mounted) return;
    context.pushReplacement(
      AppRoutes.tradeOrderSuccessWithOrderId(
        orderId,
        type: orderInfoType,
        variant: TradeOrderSuccessVariant.modify.queryValue,
      ),
    );
    onSuccessCleanup();
    return;
  }

  context.showAppMessage(
    '${l10n.tradeOrderModifyFailed} (${response.statusCode})',
    variant: AppMessageVariant.error,
    duration: AppToast.tradeErrorDuration,
  );
}

/// Navigates to the success page on MQTT place-order success; toast on failure.
Future<void> handlePlaceOrderMqttResponse({
  required WidgetRef ref,
  required BuildContext context,
  required AppLocalizations l10n,
  required TradeMqttResponse response,
  required VoidCallback clearPending,
  required String? pendingSymbol,
  required int orderInfoType,
}) async {
  if (pendingSymbol == null) return;

  clearPending();
  if (!context.mounted) return;

  if (response.isSuccess) {
    final orderId = await TradeOrderSuccessResolver.resolve(
      response: response,
      orderInfoType: orderInfoType,
      repository: ref.read(tradeOrdersRepositoryProvider),
      symbol: pendingSymbol,
    );
    if (!context.mounted) return;
    if (orderId != null && orderId.isNotEmpty) {
      ref.invalidate(pendOrderListProvider);
      openTradeOrderSuccessPage(
        context,
        orderId: orderId,
        infoType: orderInfoType,
      );
      return;
    }
  }

  if (!context.mounted) return;
  context.showAppMessage(
    tradeResultMessage(l10n, response),
    variant: response.isSuccess
        ? AppMessageVariant.normal
        : AppMessageVariant.error,
    duration: AppToast.tradeErrorDuration,
  );
}

void exitTradeOrderSuccessToRoot(BuildContext context) {
  context.go(AppRoutes.trade);
}
