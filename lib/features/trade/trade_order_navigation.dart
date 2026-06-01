import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/features/trade/domain/open_position.dart';
import 'package:ap_securities/features/trade/domain/pending_order.dart';
import 'package:ap_securities/features/trade/domain/trade_order_modify_context.dart';
import 'package:ap_securities/features/trade/providers/trade_order_modify_provider.dart';
import 'package:ap_securities/features/trade/providers/trade_order_providers.dart';
import 'package:ap_securities/providers/app_shell_theme.dart';
import 'package:ap_securities/shell/view/main_shell_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Leaves trade order and lands on the trade tab with light shell theme.
void exitTradeOrderToTradeTab(BuildContext context, WidgetRef ref) {
  ref.read(tradeOrderModifyContextProvider.notifier).state = null;
  setShellBranchIndex(ref, kTradeShellBranchIndex);
  context.go(AppRoutes.trade);
}

/// Opens trade order screen to confirm closing an open position.
void openClosePositionOrder(
  BuildContext context,
  WidgetRef ref,
  OpenPosition position,
) {
  final modify = TradeOrderModifyContext.fromPositionClose(position);
  ref.read(tradeOrderModifyContextProvider.notifier).state = modify;
  context.push(AppRoutes.tradeOrderWithSymbol(position.symbol));
}

/// Opens trade order screen in modify SL/TP mode for an open position.
void openModifyPositionOrder(
  BuildContext context,
  WidgetRef ref,
  OpenPosition position,
) {
  final modify = TradeOrderModifyContext.fromPosition(position);
  ref.read(tradeOrderModifyContextProvider.notifier).state = modify;
  context.push(AppRoutes.tradeOrderWithSymbol(position.symbol));
}

/// Opens trade order screen in modify mode for a pending order.
void openModifyPendingOrder(
  BuildContext context,
  WidgetRef ref,
  PendingOrder order,
) {
  final modify = TradeOrderModifyContext.fromPendingOrder(order);
  ref.read(tradeOrderModifyContextProvider.notifier).state = modify;
  context.push(AppRoutes.tradeOrderWithSymbol(order.symbol));
}

/// Pops modify order page or exits to trade tab for a normal order.
void leaveTradeOrderPage(BuildContext context, WidgetRef ref) {
  if (ref.read(tradeOrderModifyContextProvider) != null) {
    ref.read(tradeOrderModifyContextProvider.notifier).state = null;
    if (context.canPop()) {
      context.pop();
    }
    return;
  }
  exitTradeOrderToTradeTab(context, ref);
}
