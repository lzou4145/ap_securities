import 'dart:async';

import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/features/chart/chart_navigation.dart';
import 'package:ap_securities/features/trade/application/cancel_pending_order_action.dart';
import 'package:ap_securities/features/trade/domain/pending_order.dart';
import 'package:ap_securities/features/trade/presentation/widgets/trade_list_swipe_actions.dart';
import 'package:ap_securities/features/trade/presentation/widgets/trade_pending_order_row.dart';
import 'package:ap_securities/features/trade/trade_order_navigation.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pending order row with left-swipe icon actions (cancel / modify / trade / chart).
class TradePendingOrderSlidableRow extends ConsumerWidget {
  const TradePendingOrderSlidableRow({
    required this.order,
    super.key,
  });

  final PendingOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return buildTradeListSlidable(
      slidableKey: ValueKey('pending-${order.id}'),
      groupTag: 'trade-pending-orders',
      actions: [
        TradeListSwipeAction(
          icon: Icons.cancel_outlined,
          onTap: () {
            unawaited(
              cancelPendingOrder(
                ref: ref,
                context: context,
                l10n: l10n,
                order: order,
              ),
            );
          },
        ),
        TradeListSwipeAction(
          icon: Icons.edit_outlined,
          onTap: () => openModifyPendingOrder(context, ref, order),
        ),
        TradeListSwipeAction(
          icon: Icons.add,
          onTap: () => context.push(AppRoutes.tradeOrderWithSymbol(order.symbol)),
        ),
        TradeListSwipeAction(
          icon: Icons.candlestick_chart_outlined,
          onTap: () => openChartTab(context, ref, order.symbol),
        ),
      ],
      child: TradePendingOrderRow(order: order),
    );
  }
}
