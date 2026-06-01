import 'package:ap_securities/core/theme/app_fonts.dart';
import 'package:ap_securities/features/market/domain/market_price_format.dart';
import 'package:ap_securities/features/market/providers/market_watchlist_notifier.dart';
import 'package:ap_securities/features/trade/domain/open_position.dart';
import 'package:ap_securities/features/trade/domain/trade_side.dart';
import 'package:ap_securities/features/trade/presentation/trade_formatters.dart';
import 'package:ap_securities/features/trade/presentation/trade_page_colors.dart';
import 'package:ap_securities/features/trade/presentation/widgets/trade_list_expand_details.dart';
import 'package:ap_securities/features/trade/presentation/widgets/trade_list_item_formatters.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TradePositionRow extends ConsumerStatefulWidget {
  const TradePositionRow({
    required this.position,
    super.key,
  });

  final OpenPosition position;

  @override
  ConsumerState<TradePositionRow> createState() => _TradePositionRowState();
}

class _TradePositionRowState extends ConsumerState<TradePositionRow> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final position = widget.position;
    final quotes = ref.watch(marketWatchlistProvider).valueOrNull;
    final decimalPlace = decimalPlaceForSymbol(quotes, position.symbol);

    final sideLabel = position.side == TradeSide.buy
        ? l10n.historyTradeBuy
        : l10n.historyTradeSell;
    final sideColor = position.side == TradeSide.buy
        ? TradePageColors.buyBlue
        : TradePageColors.sellRed;
    final profitColor = position.profit >= 0
        ? TradePageColors.profitPositive
        : TradePageColors.profitNegative;
    final volumeStr = TradeFormatters.volume(position.volume);
    final priceLine = TradeListItemFormatters.priceRange(
      from: position.priceFrom,
      to: position.priceTo,
      decimalPlace: decimalPlace,
    );
    final timeLine =
        TradeListItemFormatters.timestampFromSeconds(position.timestampSec);

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
                                text: '${position.symbol}, ',
                                style: AppFonts.tradeListSymbol(),
                              ),
                              TextSpan(
                                text: '$sideLabel $volumeStr',
                                style: AppFonts.tradeListSide(sideColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          priceLine,
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
                    TradeFormatters.amount(position.profit),
                    style: AppFonts.tradeListProfit(profitColor),
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
                      position.stopLoss,
                      decimalPlace,
                    ),
                  ),
                  TradeListDetailEntry(
                    label: l10n.tradeOrderTakeProfit,
                    value: TradeListItemFormatters.optionalPrice(
                      position.takeProfit,
                      decimalPlace,
                    ),
                  ),
                  TradeListDetailEntry(
                    label: l10n.tradeDetailOrderId,
                    value: position.id,
                  ),
                ],
                rightColumn: [
                  TradeListDetailEntry(
                    label: l10n.tradeDetailSwapFee,
                    value: TradeListItemFormatters.optionalMoney(
                      position.overnightFee,
                    ),
                  ),
                  TradeListDetailEntry(
                    label: l10n.tradeDetailTax,
                    value: TradeListItemFormatters.optionalMoney(position.tax),
                  ),
                  TradeListDetailEntry(
                    label: l10n.tradeDetailCommission,
                    value: TradeListItemFormatters.optionalMoney(position.fee),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
