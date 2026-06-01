import 'package:ap_securities/core/mqtt/trade_mqtt_commands.dart';
import 'package:ap_securities/core/ui/app_toast.dart';
import 'package:ap_securities/core/mqtt/trade_mqtt_response.dart';
import 'package:ap_securities/features/market/domain/market_price_format.dart';
import 'package:ap_securities/features/trade/providers/trade_mqtt_providers.dart';
import 'package:ap_securities/features/trade/providers/trade_mqtt_response_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:ap_securities/features/trade/domain/order_info_query_type.dart';
import 'package:ap_securities/features/trade/trade_order_success_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared MQTT instant trade (TRADE command) used by order page and chart tab.
Future<void> submitInstantTrade({
  required WidgetRef ref,
  required BuildContext context,
  required AppLocalizations l10n,
  required String symbol,
  required double lot,
  required bool isBuy,
  double? takeProfit,
  double? stopLoss,
}) async {
  if (symbol.isEmpty) return;

  final mqtt = ref.read(tradeMqttClientProvider);
  if (!mqtt.isConnected) {
    if (!context.mounted) return;
    context.showAppMessage(
      l10n.tradeOrderMqttOffline,
      variant: AppMessageVariant.error,
    );
    return;
  }

  if (lot < 0.01) {
    if (!context.mounted) return;
    context.showAppMessage(l10n.tradeOrderLotTooSmall);
    return;
  }

  final command = TradeMqttCommands.instantTrade(
    symbol: symbol,
    lot: lot,
    takeProfit: takeProfit,
    stopLoss: stopLoss,
    isBuy: isBuy,
  );

  ref.read(tradeInstantOrderPendingProvider.notifier).state = symbol;
  mqtt.publishCommand(command);

  // if (!context.mounted) return;
  // ScaffoldMessenger.of(context).showSnackBar(
  //   SnackBar(
  //     content: Text(l10n.tradeOrderSubmitting),
  //     duration: const Duration(seconds: 2),
  //   ),
  // );
}

Future<void> finishInstantTradeResponse({
  required WidgetRef ref,
  required BuildContext context,
  required AppLocalizations l10n,
  required TradeMqttResponse response,
  required String? pendingSymbol,
  required VoidCallback clearPending,
}) {
  return handlePlaceOrderMqttResponse(
    ref: ref,
    context: context,
    l10n: l10n,
    response: response,
    pendingSymbol: pendingSymbol,
    clearPending: clearPending,
    orderInfoType: OrderInfoQueryType.instant,
  );
}

String tradeResultMessage(AppLocalizations l10n, TradeMqttResponse response) {
  if (response.message.isNotEmpty) {
    return response.message;
  }
  if (response.isSuccess) {
    return l10n.tradeOrderSubmitSuccess;
  }
  if (response.statusCode != 0) {
    return '${l10n.tradeOrderSubmitFailed} (${response.statusCode})';
  }
  return l10n.tradeOrderSubmitFailed;
}

String formatTradePrice(double price, {int decimalPlace = 2}) {
  return formatMarketPrice(price, decimalPlace: decimalPlace);
}
