import 'package:ap_securities/core/theme/app_fonts.dart';
import 'package:ap_securities/features/history/domain/history_period.dart';
import 'package:ap_securities/features/history/domain/trade_history_record.dart';
import 'package:ap_securities/features/history/presentation/widgets/history_page_colors.dart';
import 'package:ap_securities/features/market/domain/market_price_format.dart';
import 'package:ap_securities/features/market/providers/market_watchlist_notifier.dart';
import 'package:ap_securities/features/trade/presentation/trade_formatters.dart';
import 'package:ap_securities/features/trade/presentation/widgets/trade_list_expand_details.dart';
import 'package:ap_securities/features/trade/presentation/widgets/trade_list_item_formatters.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TradeHistoryRow extends ConsumerStatefulWidget {
  const TradeHistoryRow({
    required this.record,
    super.key,
  });

  final TradeHistoryRecord record;

  @override
  ConsumerState<TradeHistoryRow> createState() => _TradeHistoryRowState();
}

class _TradeHistoryRowState extends ConsumerState<TradeHistoryRow> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final record = widget.record;
    final quotes = ref.watch(marketWatchlistProvider).valueOrNull;
    final decimalPlace = decimalPlaceForSymbol(quotes, record.symbol);

    final isBuy = record.side == TradeSide.buy;
    final sideColor =
        isBuy ? HistoryPageColors.buyBlue : HistoryPageColors.sellRed;
    final sideLabel = isBuy ? l10n.historyTradeBuy : l10n.historyTradeSell;
    final profitColor = record.profit >= 0
        ? HistoryPageColors.profitPositive
        : HistoryPageColors.profitNegative;
    final volumeStr = TradeFormatters.volume(record.volume);
    final priceLine = TradeListItemFormatters.priceRange(
      from: record.openPrice,
      to: record.closePrice,
      decimalPlace: decimalPlace,
    );
    final timeLine = TradeListItemFormatters.timestampFromSeconds(
      record.closedAt.millisecondsSinceEpoch ~/ 1000,
    );

    return Column(
      children: [
        Material(
          color: HistoryPageColors.background,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    HistoryPageColors.listHorizontalPadding,
                    12,
                    HistoryPageColors.listHorizontalPadding,
                    12,
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${record.symbol}, ',
                                    style: AppFonts.historyListSymbol(),
                                  ),
                                  TextSpan(
                                    text: '$sideLabel $volumeStr',
                                    style: AppFonts.historyListSide(sideColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeLine,
                            style: AppFonts.historyListTime(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              priceLine,
                              style: AppFonts.historyListPriceRange(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            TradeFormatters.amount(record.profit),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: profitColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_expanded)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: HistoryPageColors.listHorizontalPadding,
                      right: HistoryPageColors.listHorizontalPadding,
                    ),
                    child: TradeListExpandDetails(
                      horizontalPadding: 0,
                      leftColumn: [
                        TradeListDetailEntry(
                          label: l10n.tradeOrderStopLoss,
                          value: TradeListItemFormatters.optionalPrice(
                            record.stopLoss,
                            decimalPlace,
                          ),
                        ),
                        TradeListDetailEntry(
                          label: l10n.tradeOrderTakeProfit,
                          value: TradeListItemFormatters.optionalPrice(
                            record.takeProfit,
                            decimalPlace,
                          ),
                        ),
                        TradeListDetailEntry(
                          label: l10n.tradeDetailOrderId,
                          value: record.id,
                        ),
                      ],
                      rightColumn: [
                        TradeListDetailEntry(
                          label: l10n.tradeDetailSwapFee,
                          value: TradeListItemFormatters.optionalMoney(
                            record.overnightFee,
                          ),
                        ),
                        TradeListDetailEntry(
                          label: l10n.tradeDetailTax,
                          value:
                              TradeListItemFormatters.optionalMoney(record.tax),
                        ),
                        TradeListDetailEntry(
                          label: l10n.tradeDetailCommission,
                          value:
                              TradeListItemFormatters.optionalMoney(record.fee),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          indent: HistoryPageColors.listDividerInset,
          endIndent: HistoryPageColors.listDividerInset,
          color: HistoryPageColors.divider,
        ),
      ],
    );
  }
}
