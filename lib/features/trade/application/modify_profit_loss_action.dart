import 'dart:async';

import 'package:ap_securities/core/mqtt/trade_mqtt_commands.dart';
import 'package:ap_securities/core/ui/app_toast.dart';
import 'package:ap_securities/features/trade/providers/trade_mqtt_providers.dart';
import 'package:ap_securities/features/trade/domain/trade_order_modify_context.dart';
import 'package:ap_securities/features/trade/providers/trade_order_modify_provider.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> submitModifyProfitLoss({
  required WidgetRef ref,
  required BuildContext context,
  required AppLocalizations l10n,
  required TradeOrderModifyContext modify,
  required double? takeProfit,
  required double? stopLoss,
}) async {
  final mqtt = ref.read(tradeMqttClientProvider);
  if (!mqtt.isConnected) {
    context.showAppMessage(
      l10n.tradeOrderMqttOffline,
      variant: AppMessageVariant.error,
    );
    return;
  }

  final command = modify.isPending
      ? TradeMqttCommands.orderModifyProfitLoss(
          orderId: modify.orderId,
          takeProfit: takeProfit,
          stopLoss: stopLoss,
        )
      : TradeMqttCommands.modifyProfitLoss(
          orderId: modify.orderId,
          takeProfit: takeProfit,
          stopLoss: stopLoss,
        );

  ref.read(tradeModifyProfitLossPendingProvider.notifier).state =
      modify.orderId;
  mqtt.publishCommand(command);

  // if (!context.mounted) return;
  // ScaffoldMessenger.of(context).showSnackBar(
  //   SnackBar(
  //     content: Text(l10n.tradeOrderSubmitting),
  //     duration: const Duration(seconds: 2),
  //   ),
  // );
}

void showModifyProfitLossResult(
  BuildContext context,
  AppLocalizations l10n, {
  required bool success,
  required String message,
}) {
  context.showAppMessage(
    message,
    variant: success ? AppMessageVariant.normal : AppMessageVariant.error,
    duration: AppToast.tradeErrorDuration,
  );
}
