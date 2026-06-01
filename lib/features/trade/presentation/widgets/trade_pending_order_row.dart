import 'package:ap_securities/core/theme/app_fonts.dart';
import 'package:ap_securities/features/market/domain/market_price_format.dart';
import 'package:ap_securities/features/market/providers/market_watchlist_notifier.dart';
import 'package:ap_securities/features/trade/domain/pending_order.dart';
import 'package:ap_securities/features/trade/presentation/trade_formatters.dart';
import 'package:ap_securities/features/trade/presentation/trade_page_colors.dart';
import 'package:ap_securities/features/trade/presentation/widgets/trade_list_expand_details.dart';
import 'package:ap_securities/features/trade/presentation/widgets/trade_list_item_formatters.dart';
import 'package:ap_securities/features/trade/providers/trade_order_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TradePendingOrderRow extends ConsumerStatefulWidget {
  const TradePendingOrderRow({
    required this.order,
    super.key,
  });

  final PendingOrder order;

  @override
  ConsumerState<TradePendingOrderRow> createState() =>
      _TradePendingOrderRowState();
}

class _TradePendingOrderRowState extends ConsumerState<TradePendingOrderRow> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final order = widget.order;
    final quotes = ref.watch(marketWatchlistProvider).valueOrNull;
    final decimalPlace = decimalPlaceForSymbol(quotes, order.symbol);

    final kindLabel = _kindLabel(l10n, order.kind);
    final sideColor =
        order.isBuy ? TradePageColors.buyBlue : TradePageColors.sellRed;
    final lotStr = TradeFormatters.volume(order.lot);
    final limitStr =
        TradeListItemFormatters.price(order.limitPrice, decimalPlace);
    final marketPrice = _resolveMarketPrice(ref);
    final marketStr =
        TradeListItemFormatters.price(marketPrice, decimalPlace);
    final timeLine = TradeListItemFormatters.timestampFromApi(order.createdAt);

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${order.symbol}, ',
                                style: AppFonts.tradeListSymbol(),
                              ),
                              TextSpan(
                                text: kindLabel,
                                style: AppFonts.tradeListSide(sideColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.tradePendingLotAtPrice(lotStr, limitStr),
                          style: const TextStyle(
                            fontSize: 13,
                            color: TradePageColors.subtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    marketStr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: TradePageColors.title,
                    ),
                  ),
                ],
              ),
            ),
            if (_expanded)
              TradeListExpandDetails(
                timestamp: timeLine,
                leftColumn: [
                  TradeListDetailEntry(
                    label: l10n.tradeOrderStopLoss,
                    value: TradeListItemFormatters.optionalPrice(
                      order.stopLoss,
                      decimalPlace,
                    ),
                  ),
                  TradeListDetailEntry(
                    label: l10n.tradeOrderTakeProfit,
                    value: TradeListItemFormatters.optionalPrice(
                      order.takeProfit,
                      decimalPlace,
                    ),
                  ),
                  TradeListDetailEntry(
                    label: l10n.tradeDetailOrderId,
                    value: order.id,
                  ),
                ],
                rightColumn: [
                  TradeListDetailEntry(
                    label: l10n.tradeDetailSwapFee,
                    value: TradeListItemFormatters.optionalMoney(
                      order.overnightFee,
                    ),
                  ),
                  TradeListDetailEntry(
                    label: l10n.tradeDetailTax,
                    value: TradeListItemFormatters.optionalMoney(order.tax),
                  ),
                  TradeListDetailEntry(
                    label: l10n.tradeDetailCommission,
                    value: TradeListItemFormatters.optionalMoney(order.fee),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  double _resolveMarketPrice(WidgetRef ref) {
    final order = widget.order;
    if (order.currentPrice > 0) return order.currentPrice;
    final quote = ref.watch(tradeOrderQuoteProvider(order.symbol)).valueOrNull;
    if (quote == null) return order.limitPrice;
    return order.isBuy ? quote.ask : quote.bid;
  }

  String _kindLabel(AppLocalizations l10n, PendingOrderKind kind) {
    return switch (kind) {
      PendingOrderKind.buyLimit => l10n.tradePendingBuyLimit,
      PendingOrderKind.sellLimit => l10n.tradePendingSellLimit,
      PendingOrderKind.buyStop => l10n.tradePendingBuyStop,
      PendingOrderKind.sellStop => l10n.tradePendingSellStop,
    };
  }
}
