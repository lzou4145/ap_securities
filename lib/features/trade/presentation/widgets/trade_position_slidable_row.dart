import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/features/chart/chart_navigation.dart';
import 'package:ap_securities/features/trade/domain/open_position.dart';
import 'package:ap_securities/features/trade/presentation/widgets/trade_list_swipe_actions.dart';
import 'package:ap_securities/features/trade/presentation/widgets/trade_position_row.dart';
import 'package:ap_securities/features/trade/trade_order_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Position row with left-swipe icon actions (close / modify / trade / chart).
class TradePositionSlidableRow extends ConsumerWidget {
  const TradePositionSlidableRow({
    required this.position,
    this.showModifyProfitLoss = true,
    super.key,
  });

  final OpenPosition position;
  final bool showModifyProfitLoss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = <TradeListSwipeAction>[
      TradeListSwipeAction(
        icon: Icons.check_circle_outline,
        onTap: () => openClosePositionOrder(context, ref, position),
      ),
      if (showModifyProfitLoss)
        TradeListSwipeAction(
          icon: Icons.edit_outlined,
          onTap: () => openModifyPositionOrder(context, ref, position),
        ),
      TradeListSwipeAction(
        icon: Icons.add,
        onTap: () => context.push(AppRoutes.tradeOrderWithSymbol(position.symbol)),
      ),
      TradeListSwipeAction(
        icon: Icons.candlestick_chart_outlined,
        onTap: () => openChartTab(context, ref, position.symbol),
      ),
    ];

    return buildTradeListSlidable(
      slidableKey: ValueKey('position-${position.id}'),
      groupTag: showModifyProfitLoss ? 'trade-positions' : 'trade-follow-positions',
      actions: actions,
      child: TradePositionRow(position: position),
    );
  }
}
