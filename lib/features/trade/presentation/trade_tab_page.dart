import 'dart:async';

import 'package:ap_securities/core/network/api_exception.dart';
import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/core/theme/app_fonts.dart';
import 'package:ap_securities/features/chart/presentation/widgets/chart_resolution_sidebar.dart';
import 'package:ap_securities/features/trade/domain/pending_order.dart';
import 'package:ap_securities/features/trade/domain/trade_page_data.dart';
import 'package:ap_securities/features/trade/presentation/trade_formatters.dart';
import 'package:ap_securities/features/trade/presentation/trade_order_success_sound.dart';
import 'package:ap_securities/features/trade/presentation/trade_page_colors.dart';
import 'package:ap_securities/features/trade/presentation/widgets/trade_pending_order_slidable_row.dart';
import 'package:ap_securities/core/mqtt/trade_mqtt_response.dart';
import 'package:ap_securities/features/trade/application/instant_trade_action.dart';
import 'package:ap_securities/core/ui/app_toast.dart';
import 'package:ap_securities/features/trade/presentation/widgets/trade_position_slidable_row.dart';
import 'package:ap_securities/features/trade/providers/trade_mqtt_response_providers.dart';
import 'package:ap_securities/features/trade/providers/trade_order_modify_provider.dart';
import 'package:ap_securities/features/trade/providers/trade_tab_providers.dart';
import 'package:ap_securities/features/trade/presentation/widgets/trade_section_header.dart';
import 'package:ap_securities/features/trade/presentation/widgets/trade_summary_row.dart';
import 'package:ap_securities/features/trade/providers/pend_order_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

class TradeTabPage extends ConsumerStatefulWidget {
  const TradeTabPage({super.key});

  @override
  ConsumerState<TradeTabPage> createState() => _TradeTabPageState();
}

class _TradeTabPageState extends ConsumerState<TradeTabPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.listen(tradeMqttLastResponseProvider, (previous, next) {
      _onTradeMqttResponse(l10n, next?.response);
    });

    final tabState = ref.watch(tradeTabProvider);
    final data = tabState.toPageData();
    final ordersAsync = ref.watch(pendOrderListProvider);

    return _TradeBody(
      data: data,
      l10n: l10n,
      ordersAsync: ordersAsync,
    );
  }

  void _onTradeMqttResponse(
    AppLocalizations l10n,
    TradeMqttResponse? response,
  ) {
    if (response == null) return;

    switch (response.operationType) {
      case TradeMqttOperationType.closeOrderBack:
        _finishCloseOrder(l10n, response);
      case TradeMqttOperationType.orderRemoveBack:
        _finishRemovePendingOrder(l10n, response);
      default:
        break;
    }
  }

  void _finishCloseOrder(AppLocalizations l10n, TradeMqttResponse response) {
    if (ref.read(tradeOrderModifyContextProvider)?.isClose == true) {
      return;
    }
    final pendingOrderId = ref.read(tradeCloseOrderPendingProvider);
    if (pendingOrderId == null) return;

    ref.read(tradeCloseOrderPendingProvider.notifier).state = null;
    if (response.isSuccess) {
      ref.read(tradeTabProvider.notifier).removePosition(pendingOrderId);
    }
    // Close confirm page handles success navigation; only show errors here.
    if (!response.isSuccess) {
      _showTradeResultMessage(l10n, response);
    }
  }

  void _finishRemovePendingOrder(
    AppLocalizations l10n,
    TradeMqttResponse response,
  ) {
    // Pending-order modify page handles remove UX (pop + snackbar).
    final modify = ref.read(tradeOrderModifyContextProvider);
    if (modify != null && modify.isPending) return;

    final pendingOrderId = ref.read(tradeRemoveOrderPendingProvider);
    if (pendingOrderId == null) return;

    ref.read(tradeRemoveOrderPendingProvider.notifier).state = null;
    if (response.isSuccess) {
      ref.read(pendOrderListProvider.notifier).removeById(pendingOrderId);
      unawaited(TradeOrderSuccessSound.play());
      return;
    }
    _showTradeResultMessage(l10n, response);
  }

  void _showTradeResultMessage(
    AppLocalizations l10n,
    TradeMqttResponse response,
  ) {
    if (!mounted) return;
    context.showAppMessage(
      tradeResultMessage(l10n, response),
      variant: AppMessageVariant.error,
      duration: AppToast.tradeErrorDuration,
    );
  }
}

class _TradeBody extends StatelessWidget {
  const _TradeBody({
    required this.data,
    required this.l10n,
    required this.ordersAsync,
  });

  final TradePageData data;
  final AppLocalizations l10n;
  final AsyncValue<List<PendingOrder>> ordersAsync;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final isProfit = data.totalProfitUsd >= 0;
    final headerColor =
        isProfit ? TradePageColors.headerProfit : TradePageColors.headerLoss;
    final profitText =
        '${TradeFormatters.amount(data.totalProfitUsd)} ${l10n.tradeCurrencyUsd}';

    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: _TradeProfitHeader(
              topPadding: topPadding,
              headerColor: headerColor,
              profitText: profitText,
              tradeLabel: l10n.navTrade,
              onTradePressed: () => context.push(AppRoutes.tradeOrder),
            ),
          ),
          Expanded(
            child: SlidableAutoCloseBehavior(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: TradeSummaryRow(
                      label: l10n.tradeBalance,
                      value: data.summary.balance,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: TradeSummaryRow(
                      label: l10n.tradeEquity,
                      value: data.summary.equity,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: TradeSummaryRow(
                      label: l10n.tradeMargin,
                      value: data.summary.margin,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: TradeSummaryRow(
                      label: l10n.tradeFreeMargin,
                      value: data.summary.freeMargin,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: TradeSummaryRow(
                      label: l10n.tradeMarginLevel,
                      value: data.summary.marginLevelPercent,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: TradeSectionHeader(
                      title: l10n.tradePositionsSection,
                    ),
                  ),
                  ..._itemSlivers(
                    data.positions.isEmpty ? 0 : data.positions.length,
                    (i) => TradePositionSlidableRow(
                      position: data.positions[i],
                    ),
                    empty: data.positions.isEmpty
                        ? _EmptyHint(text: l10n.tradePositionsEmpty)
                        : null,
                  ),
                  SliverToBoxAdapter(
                    child: TradeSectionHeader(
                      title: l10n.tradeFollowSection,
                    ),
                  ),
                  ..._itemSlivers(
                    data.followPositions.isEmpty ? 0 : data.followPositions.length,
                    (i) => TradePositionSlidableRow(
                      position: data.followPositions[i],
                      showModifyProfitLoss: false,
                    ),
                    empty: data.followPositions.isEmpty
                        ? _EmptyHint(text: l10n.tradeFollowEmpty)
                        : null,
                  ),
                  SliverToBoxAdapter(
                    child: TradeSectionHeader(
                      title: l10n.tradeOrdersSection,
                    ),
                  ),
                  ..._orderSlivers(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _orderSlivers() {
    return ordersAsync.when(
      loading: () => [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
      error: (e, _) => [
        SliverToBoxAdapter(
          child: _EmptyHint(
            text: e is ApiException ? e.message : '$e',
          ),
        ),
      ],
      data: (orders) => _itemSlivers(
        orders.isEmpty ? 0 : orders.length,
        (i) => TradePendingOrderSlidableRow(order: orders[i]),
        empty: orders.isEmpty ? _EmptyHint(text: l10n.tradeOrdersEmpty) : null,
      ),
    );
  }

  List<Widget> _itemSlivers(
    int count,
    Widget Function(int index) builder, {
    Widget? empty,
  }) {
    if (count == 0) {
      return empty == null ? [] : [SliverToBoxAdapter(child: empty)];
    }
    final slivers = <Widget>[];
    for (var i = 0; i < count; i++) {
      if (i > 0) {
        slivers.add(
          const SliverToBoxAdapter(
            child: Divider(
              height: 1,
              thickness: 1,
              color: TradePageColors.divider,
            ),
          ),
        );
      }
      slivers.add(SliverToBoxAdapter(child: builder(i)));
    }
    return slivers;
  }
}

class _TradeProfitHeader extends StatelessWidget {
  const _TradeProfitHeader({
    required this.topPadding,
    required this.headerColor,
    required this.profitText,
    required this.tradeLabel,
    required this.onTradePressed,
  });

  final double topPadding;
  final Color headerColor;
  final String profitText;
  final String tradeLabel;
  final VoidCallback onTradePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: headerColor,
      padding: EdgeInsets.fromLTRB(8, topPadding + 12, 8, 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            profitText,
            textAlign: TextAlign.center,
            style: AppFonts.tradeTotalProfit(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ChartResolutionNavButton(
              label: tradeLabel,
              onTap: onTradePressed,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: TradePageColors.subtitle),
        ),
      ),
    );
  }
}
