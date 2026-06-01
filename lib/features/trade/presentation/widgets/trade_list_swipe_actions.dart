import 'package:ap_securities/features/trade/presentation/trade_page_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// Blue trailing pane with a row of white swipe icons (shared by trade lists).
class TradeListSwipeActionPane extends StatelessWidget {
  const TradeListSwipeActionPane({
    required this.actions,
    super.key,
  });

  final List<TradeListSwipeAction> actions;

  static const double paneWidth = 176;

  @override
  Widget build(BuildContext context) {
    void run(VoidCallback action) {
      action();
      Slidable.of(context)?.close();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final action in actions)
          TradeListSwipeIcon(
            icon: action.icon,
            onTap: () => run(action.onTap),
          ),
      ],
    );
  }
}

class TradeListSwipeAction {
  const TradeListSwipeAction({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;
}

class TradeListSwipeIcon extends StatelessWidget {
  const TradeListSwipeIcon({
    required this.icon,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 22, color: Colors.white),
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// Wraps [child] in a slidable with the standard 4-icon blue action pane.
Widget buildTradeListSlidable({
  required Key slidableKey,
  required String groupTag,
  required Widget child,
  required List<TradeListSwipeAction> actions,
}) {
  return Builder(
    builder: (context) {
      final screenWidth = MediaQuery.sizeOf(context).width;
      final extentRatio =
          (TradeListSwipeActionPane.paneWidth / screenWidth).clamp(0.38, 0.52);

      return Slidable(
        key: slidableKey,
        groupTag: groupTag,
        closeOnScroll: true,
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: extentRatio,
          children: [
            CustomSlidableAction(
              flex: 4,
              autoClose: true,
              onPressed: (_) {},
              backgroundColor: TradePageColors.buyBlue,
              padding: EdgeInsets.zero,
              child: TradeListSwipeActionPane(actions: actions),
            ),
          ],
        ),
        child: child,
      );
    },
  );
}
