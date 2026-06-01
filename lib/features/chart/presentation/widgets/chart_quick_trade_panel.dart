import 'package:ap_securities/core/theme/app_fonts.dart';
import 'package:ap_securities/features/chart/providers/chart_quick_trade_providers.dart';
import 'package:ap_securities/features/market/domain/market_price_format.dart';
import 'package:ap_securities/features/market/domain/market_quote.dart';
import 'package:ap_securities/features/market/providers/market_watchlist_notifier.dart';
import 'package:ap_securities/features/trade/application/instant_trade_action.dart';
import 'package:ap_securities/features/trade/presentation/trade_order_colors.dart';
import 'package:ap_securities/features/trade/providers/trade_order_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom quick buy/sell bar on the chart tab (instant MQTT trade).
class ChartQuickTradePanel extends ConsumerWidget {
  const ChartQuickTradePanel({
    required this.symbol,
    super.key,
  });

  final String symbol;

  static const _tradeBlue = Color(0xFF2D8BFF);

  static MarketQuote? _marketQuoteFor(WidgetRef ref, String symbol) {
    final list = ref.watch(marketWatchlistProvider).valueOrNull;
    if (list == null || symbol.isEmpty) return null;
    for (final row in list) {
      if (row.symbol == symbol) return row;
    }
    return null;
  }

  static String _quotePriceLabel({
    required MarketQuote? marketRow,
    required double value,
  }) {
    if (value <= 0) return '--';
    final places = marketRow?.decimalPlace ?? 2;
    return formatMarketPrice(value, decimalPlace: places);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final quoteAsync = ref.watch(tradeOrderQuoteProvider(symbol));

    final quote = quoteAsync.valueOrNull;
    final bid = quote?.bid ?? 0;
    final ask = quote?.ask ?? 0;
    final marketRow = _marketQuoteFor(ref, symbol);
    final bidText = _quotePriceLabel(marketRow: marketRow, value: bid);
    final askText = _quotePriceLabel(marketRow: marketRow, value: ask);
    final colorScheme = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: divider),
          bottom: BorderSide(color: divider),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              Expanded(
                child: _TradeSideButton(
                  label: l10n.historyTradeSell.toUpperCase(),
                  price: bidText,
                  backgroundColor: TradeOrderColors.sellRed,
                  onTap: symbol.isEmpty
                      ? null
                      : () => submitInstantTrade(
                            ref: ref,
                            context: context,
                            l10n: l10n,
                            symbol: symbol,
                            lot: ref.read(chartQuickTradeLotProvider),
                            isBuy: false,
                          ),
                ),
              ),
              const _LotControl(),
              Expanded(
                child: _TradeSideButton(
                  label: l10n.historyTradeBuy.toUpperCase(),
                  price: askText,
                  backgroundColor: ChartQuickTradePanel._tradeBlue,
                  onTap: symbol.isEmpty
                      ? null
                      : () => submitInstantTrade(
                            ref: ref,
                            context: context,
                            l10n: l10n,
                            symbol: symbol,
                            lot: ref.read(chartQuickTradeLotProvider),
                            isBuy: true,
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TradeSideButton extends StatelessWidget {
  const _TradeSideButton({
    required this.label,
    required this.price,
    required this.backgroundColor,
    required this.onTap,
  });

  final String label;
  final String price;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LotControl extends ConsumerStatefulWidget {
  const _LotControl();

  static const _minLot = 0.01;
  static const _maxLot = 100.0;

  @override
  ConsumerState<_LotControl> createState() => _LotControlState();
}

class _LotControlState extends ConsumerState<_LotControl> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatLot(ref.read(chartQuickTradeLotProvider)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    ref.listen(chartQuickTradeLotProvider, (previous, next) {
      final text = _formatLot(next);
      if (_controller.text != text) {
        _controller.text = text;
      }
    });

    return Container(
      width: 132,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          left: BorderSide(color: divider),
          right: BorderSide(color: divider),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LotStepButton(
            icon: Icons.keyboard_arrow_down,
            onTap: () => _adjustLot(-0.01),
            onLongPress: () => _adjustLot(-0.1),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              onChanged: _onLotTextChanged,
              onSubmitted: (_) => _commitLotFromField(),
              onEditingComplete: _commitLotFromField,
              style: AppFonts.dinStyle(
                fontSize: 17,
                color: colorScheme.onSurface,
                height: 1.1,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          _LotStepButton(
            icon: Icons.keyboard_arrow_up,
            onTap: () => _adjustLot(0.01),
            onLongPress: () => _adjustLot(0.1),
          ),
        ],
      ),
    );
  }

  void _onLotTextChanged(String text) {
    final parsed = double.tryParse(text.trim());
    if (parsed == null) return;
    ref.read(chartQuickTradeLotProvider.notifier).state =
        parsed.clamp(_LotControl._minLot, _LotControl._maxLot);
  }

  void _commitLotFromField() {
    final parsed = double.tryParse(_controller.text.trim());
    final lot = (parsed ?? _LotControl._minLot)
        .clamp(_LotControl._minLot, _LotControl._maxLot);
    ref.read(chartQuickTradeLotProvider.notifier).state = lot;
    _controller.text = _formatLot(lot);
  }

  void _adjustLot(double delta) {
    final next = (ref.read(chartQuickTradeLotProvider) + delta)
        .clamp(_LotControl._minLot, _LotControl._maxLot);
    ref.read(chartQuickTradeLotProvider.notifier).state = next;
    _controller.text = _formatLot(next);
  }

  static String _formatLot(double lot) => lot.toStringAsFixed(2);
}

class _LotStepButton extends StatelessWidget {
  const _LotStepButton({
    required this.icon,
    required this.onTap,
    required this.onLongPress,
  });

  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.onSurfaceVariant),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Icon(icon, color: colorScheme.onSurface, size: 22),
      ),
    );
  }
}
