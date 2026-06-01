import 'package:ap_securities/core/mqtt/trade_mqtt_commands.dart';
import 'package:ap_securities/features/market/domain/market_price_format.dart';
import 'package:ap_securities/features/market/providers/market_watchlist_notifier.dart';
import 'package:ap_securities/features/trade/domain/pending_order.dart';
import 'package:ap_securities/features/trade/presentation/widgets/cancel_pending_order_dialog.dart';
import 'package:ap_securities/core/ui/app_toast.dart';
import 'package:ap_securities/features/trade/providers/trade_mqtt_providers.dart';
import 'package:ap_securities/features/trade/providers/trade_mqtt_response_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Confirms then publishes `ORDER_REMOVE:symbol:uuid` to cancel a pending order.
Future<void> cancelPendingOrder({
  required WidgetRef ref,
  required BuildContext context,
  required AppLocalizations l10n,
  required PendingOrder order,
}) async {
  if (order.symbol.isEmpty || order.id.isEmpty) return;

  final quotes = ref.read(marketWatchlistProvider).valueOrNull;
  final decimalPlace = decimalPlaceForSymbol(quotes, order.symbol);
  final confirmed = await showCancelPendingOrderDialog(
    context: context,
    l10n: l10n,
    order: order,
    decimalPlace: decimalPlace,
  );
  if (!confirmed || !context.mounted) return;

  final mqtt = ref.read(tradeMqttClientProvider);
  if (!mqtt.isConnected) {
    if (!context.mounted) return;
    context.showAppMessage(
      l10n.tradeOrderMqttOffline,
      variant: AppMessageVariant.error,
    );
    return;
  }

  ref.read(tradeRemoveOrderPendingProvider.notifier).state = order.id;
  mqtt.publishCommand(
    TradeMqttCommands.removePendingOrder(
      symbol: order.symbol,
      orderId: order.id,
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
