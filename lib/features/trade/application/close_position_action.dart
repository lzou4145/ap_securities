import 'package:ap_securities/core/mqtt/trade_mqtt_commands.dart';
import 'package:ap_securities/features/trade/domain/open_position.dart';
import 'package:ap_securities/core/ui/app_toast.dart';
import 'package:ap_securities/features/trade/providers/trade_mqtt_providers.dart';
import 'package:ap_securities/features/trade/providers/trade_mqtt_response_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Publishes `CLOSE_ORDER:orderId:symbol` for an open position.
Future<void> closePosition({
  required WidgetRef ref,
  required BuildContext context,
  required AppLocalizations l10n,
  required OpenPosition position,
}) async {
  if (position.id.isEmpty || position.symbol.isEmpty) return;

  final mqtt = ref.read(tradeMqttClientProvider);
  if (!mqtt.isConnected) {
    if (!context.mounted) return;
    context.showAppMessage(
      l10n.tradeOrderMqttOffline,
      variant: AppMessageVariant.error,
    );
    return;
  }

  ref.read(tradeCloseOrderPendingProvider.notifier).state = position.id;
  mqtt.publishCommand(
    TradeMqttCommands.closeOrder(
      orderId: position.id,
      symbol: position.symbol,
    ),
  );

  // if (!context.mounted) return;
  // ScaffoldMessenger.of(context).showSnackBar(
  //   SnackBar(
  //     content: Text(l10n.tradeOrderSubmitting),
  //     duration: const Duration(seconds: 2),
  //   ),
  // );
}
