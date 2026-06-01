import 'dart:async';

import 'package:ap_securities/core/theme/app_fonts.dart';
import 'package:ap_securities/features/market/domain/market_price_format.dart';
import 'package:ap_securities/features/market/domain/market_quote.dart';
import 'package:ap_securities/features/trade/domain/modify_profit_loss_validation.dart';
import 'package:ap_securities/features/market/presentation/widgets/quote_price_text.dart';
import 'package:ap_securities/features/market/providers/market_watchlist_notifier.dart';
import 'package:ap_securities/features/trade/domain/order_execution_type.dart';
import 'package:ap_securities/features/trade/domain/pending_order_validation.dart';
import 'package:ap_securities/features/trade/domain/trade_side.dart';
import 'package:ap_securities/features/trade/domain/trade_symbol_quote.dart';
import 'package:ap_securities/features/trade/presentation/trade_order_colors.dart';
import 'package:ap_securities/features/trade/presentation/trade_order_success_sound.dart';
import 'package:ap_securities/features/chart/providers/trade_order_chart_providers.dart';
import 'package:ap_securities/features/trade/presentation/widgets/trade_execution_type_picker.dart';
import 'package:ap_securities/features/trade/presentation/widgets/trade_order_candle_chart.dart';
import 'package:ap_securities/features/trade/presentation/widgets/trade_order_expiry_field.dart';
import 'package:ap_securities/core/mqtt/trade_mqtt_commands.dart';
import 'package:ap_securities/core/ui/app_toast.dart';
import 'package:ap_securities/core/mqtt/trade_mqtt_response.dart';
import 'package:ap_securities/features/trade/application/cancel_pending_order_action.dart';
import 'package:ap_securities/features/trade/application/close_position_action.dart';
import 'package:ap_securities/features/trade/application/instant_trade_action.dart';
import 'package:ap_securities/features/trade/application/modify_profit_loss_action.dart';
import 'package:ap_securities/features/trade/domain/open_position.dart';
import 'package:ap_securities/features/trade/domain/pending_order.dart';
import 'package:ap_securities/features/trade/domain/trade_order_modify_context.dart';
import 'package:ap_securities/features/trade/presentation/trade_formatters.dart';
import 'package:ap_securities/features/trade/providers/pend_order_providers.dart';
import 'package:ap_securities/features/trade/providers/trade_tab_providers.dart';
import 'package:ap_securities/features/trade/providers/trade_order_modify_provider.dart';
import 'package:ap_securities/features/trade/trade_order_navigation.dart';
import 'package:ap_securities/features/trade/domain/order_info_query_type.dart';
import 'package:ap_securities/features/trade/trade_order_success_navigation.dart';
import 'package:ap_securities/features/trade/providers/trade_mqtt_providers.dart';
import 'package:ap_securities/features/trade/providers/trade_mqtt_response_providers.dart';
import 'package:ap_securities/features/trade/providers/trade_order_providers.dart';
import 'package:ap_securities/app/theme/app_theme.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TradeOrderPage extends ConsumerStatefulWidget {
  const TradeOrderPage({this.initialSymbol, super.key});

  final String? initialSymbol;

  @override
  ConsumerState<TradeOrderPage> createState() => _TradeOrderPageState();
}

class _TradeOrderPageState extends ConsumerState<TradeOrderPage> {
  late String _symbol;
  ProviderContainer? _container;

  @override
  void initState() {
    super.initState();
    _symbol = widget.initialSymbol ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final modify = ref.read(tradeOrderModifyContextProvider);
      if (modify != null) {
        setState(() => _symbol = modify.symbol);
        if (modify.isClose && modify.volume != null) {
          ref.read(orderLotSizeProvider.notifier).state = modify.volume;
        }
        if (modify.stopLoss > 0) {
          ref.read(orderStopLossPriceProvider.notifier).state = modify.stopLoss;
        } else if (modify.isClose) {
          ref.read(orderStopLossPriceProvider.notifier).state = null;
        }
        if (modify.takeProfit > 0) {
          ref.read(orderTakeProfitPriceProvider.notifier).state =
              modify.takeProfit;
        } else if (modify.isClose) {
          ref.read(orderTakeProfitPriceProvider.notifier).state = null;
        }
      }
      _syncOrderChart();
    });
  }

  @override
  void didUpdateWidget(TradeOrderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.initialSymbol;
    if (next != null &&
        next.isNotEmpty &&
        next != oldWidget.initialSymbol &&
        next != _symbol) {
      setState(() => _symbol = next);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _clearOrderInputs();
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncOrderChart();
    });
  }

  @override
  void dispose() {
    final container = _container;
    if (container != null) {
      // Defer provider writes: Riverpod forbids updates during dispose/build.
      Future.microtask(() {
        // Keep modify context until success page clears it — avoids one frame of
        // the normal placement UI during close → success route transition.
        resetTradeOrderForm(container, clearModifyContext: false);
        container.read(tradeInstantOrderPendingProvider.notifier).state = null;
        container.read(tradePendingOrderPendingProvider.notifier).state = null;
        container.read(tradeOrderMqttExtraSymbolProvider.notifier).state = null;
        container.read(tradeModifyProfitLossPendingProvider.notifier).state =
            null;
      });
    }
    super.dispose();
  }

  void _syncOrderChart([ProviderContainer? container]) {
    if (!mounted || _symbol.isEmpty) return;
    final c = container ?? _container ?? ProviderScope.containerOf(context);
    c.read(tradeOrderMqttExtraSymbolProvider.notifier).state = _symbol;
    c.read(tradeOrderChartProvider(_symbol).notifier).ensureLoaded();
  }

  String get _titleSymbol =>
      _symbol.isNotEmpty ? _symbol : (widget.initialSymbol ?? '');

  void _clearOrderInputs() {
    FocusManager.instance.primaryFocus?.unfocus();
    clearTradeOrderInputs(ref);
  }

  @override
  Widget build(BuildContext context) {
    _container ??= ProviderScope.containerOf(context);
    final l10n = context.l10n;
    final executionType = ref.watch(orderExecutionTypeProvider);
    final lotSize = ref.watch(orderLotSizeProvider);
    final deviation = ref.watch(orderDeviationPointsProvider);
    final limitPrice = ref.watch(orderLimitPriceProvider);
    final expiryAt = ref.watch(orderExpiryAtProvider);

    ref.listen(marketWatchlistProvider, (previous, next) {
      next.whenData((quotes) {
        if (!mounted || quotes.isEmpty || _symbol.isNotEmpty) return;
        final resolved = widget.initialSymbol?.isNotEmpty == true
            ? widget.initialSymbol!
            : quotes.first.symbol;
        setState(() => _symbol = resolved);
      });
    });

    ref.watch(tradeInstantOrderPendingProvider);
    ref.watch(tradePendingOrderPendingProvider);
    ref.watch(tradeModifyProfitLossPendingProvider);
    ref.watch(tradeCloseOrderPendingProvider);
    final modifyContext = ref.watch(tradeOrderModifyContextProvider);

    ref.listen(tradeMqttLastResponseProvider, (previous, next) {
      _onTradeMqttResponse(l10n, next?.response);
    });

    if (_symbol.isNotEmpty) {
      ref.listen(tradeOrderQuoteProvider(_symbol), (previous, next) {
        next.whenData((quote) {
          if (!mounted) return;
          if (ref.read(orderLotSizeProvider) == null) {
            ref.read(orderLotSizeProvider.notifier).state = quote.defaultLot;
          }
          if (ref.read(orderExecutionTypeProvider).isInstant &&
              ref.read(orderDeviationPointsProvider) == null) {
            ref.read(orderDeviationPointsProvider.notifier).state = 5;
          }
        });
      });
    }

    final quoteAsync = _symbol.isEmpty
        ? const AsyncValue<TradeSymbolQuote>.loading()
        : ref.watch(tradeOrderQuoteProvider(_symbol));
    final watchlistQuotes = ref.watch(marketWatchlistProvider).valueOrNull;
    final decimalPlace = decimalPlaceForSymbol(watchlistQuotes, _symbol);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        leaveTradeOrderPage(context, ref);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.lightPageOverlay,
        child: Theme(
          data: AppTheme.light(),
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _OrderAppBar(
                    symbol: _titleSymbol,
                    onBack: () => leaveTradeOrderPage(context, ref),
                    onPickSymbol: modifyContext == null
                        ? () => _showSymbolSheet(context, l10n)
                        : null,
                  ),
                  Expanded(
                    child: quoteAsync.when(
                      data: (quote) {
                        if (modifyContext != null) {
                          final chartHeight =
                              (MediaQuery.sizeOf(context).height * 0.36).clamp(
                            240.0,
                            380.0,
                          );
                          if (modifyContext.isClose) {
                            return _buildClosePositionOrderLayout(
                              l10n: l10n,
                              quote: quote,
                              modify: modifyContext,
                              decimalPlace: decimalPlace,
                              chartHeight: chartHeight,
                            );
                          }
                          if (modifyContext.isPending) {
                            return _buildModifyPendingOrderLayout(
                              l10n: l10n,
                              quote: quote,
                              modify: modifyContext,
                              decimalPlace: decimalPlace,
                              chartHeight: chartHeight,
                              watchlistQuotes: watchlistQuotes,
                            );
                          }
                          return _buildModifyPositionOrderLayout(
                            l10n: l10n,
                            quote: quote,
                            modify: modifyContext,
                            decimalPlace: decimalPlace,
                            chartHeight: chartHeight,
                            watchlistQuotes: watchlistQuotes,
                          );
                        }

                        final effectiveLot = lotSize ?? quote.defaultLot;
                        final effectiveDeviation = deviation ?? 5;
                        final stopLoss = ref.watch(orderStopLossPriceProvider);
                        final takeProfit =
                            ref.watch(orderTakeProfitPriceProvider);
                        final stopLevelPoints = _stopLevelPointsForSymbol(
                          watchlistQuotes,
                          _symbol,
                        );
                        final pendingValidation = executionType.isInstant
                            ? const PendingOrderValidationResult.valid()
                            : PendingOrderValidator.validate(
                                executionType: executionType,
                                lot: effectiveLot,
                                limitPrice: limitPrice,
                                expiryAt: expiryAt,
                                bid: quote.bid,
                                ask: quote.ask,
                              );
                        final pendingPlValidation = _profitLossValidation(
                          side: executionType.tradeSide,
                          quote: quote,
                          decimalPlace: decimalPlace,
                          stopLevelPoints: stopLevelPoints,
                          stopLoss: stopLoss,
                          takeProfit: takeProfit,
                        );
                        final buyPlValidation = _profitLossValidation(
                          side: TradeSide.buy,
                          quote: quote,
                          decimalPlace: decimalPlace,
                          stopLevelPoints: stopLevelPoints,
                          stopLoss: stopLoss,
                          takeProfit: takeProfit,
                        );
                        final sellPlValidation = _profitLossValidation(
                          side: TradeSide.sell,
                          quote: quote,
                          decimalPlace: decimalPlace,
                          stopLevelPoints: stopLevelPoints,
                          stopLoss: stopLoss,
                          takeProfit: takeProfit,
                        );
                        final canSubmitPending =
                            pendingValidation.isValid &&
                                pendingPlValidation.isValid;
                        final pendingPlHint = pendingPlValidation.issue?.message(
                          l10n,
                          stopLevelPoints:
                              pendingPlValidation.effectiveStopLevelPoints,
                        );
                        final pendingDisabledHint = !pendingValidation.isValid
                            ? pendingValidation.issue?.message(l10n)
                            : pendingPlHint;
                        final buyPlHint = buyPlValidation.issue?.message(
                          l10n,
                          stopLevelPoints:
                              buyPlValidation.effectiveStopLevelPoints,
                        );
                        final sellPlHint = sellPlValidation.issue?.message(
                          l10n,
                          stopLevelPoints:
                              sellPlValidation.effectiveStopLevelPoints,
                        );
                        final profitLossHint = executionType.isInstant
                            ? null
                            : pendingPlHint;
                        final chartHeight =
                            (MediaQuery.sizeOf(context).height * 0.36).clamp(
                          240.0,
                          380.0,
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    TradeExecutionTypePicker(
                                      executionType: executionType,
                                      onChanged: (type) {
                                        _clearOrderInputs();
                                        ref
                                            .read(
                                              orderExecutionTypeProvider
                                                  .notifier,
                                            )
                                            .state = type;
                                      },
                                    ),
                                    _LotFieldRow(
                                      defaultLot: quote.defaultLot,
                                      onDecreaseLarge: () => _adjustLot(-0.1),
                                      onDecreaseSmall: () => _adjustLot(-0.01),
                                      onIncreaseSmall: () => _adjustLot(0.01),
                                      onIncreaseLarge: () => _adjustLot(0.1),
                                    ),
                                    if (executionType.showsPriceAndExpiry) ...[
                                      const Divider(
                                          height: 1,
                                          color: TradeOrderColors.divider),
                                      _InlineDoubleFieldRow(
                                        key: ValueKey(
                                          'limit_${_symbol}_${executionType.name}',
                                        ),
                                        label: l10n.tradeOrderPrice,
                                        valueProvider: orderLimitPriceProvider,
                                        hintText: l10n.tradeOrderNotSet,
                                        decimalPlace: decimalPlace,
                                        resolveLatestPrice: () =>
                                            _latestPrice(quote),
                                        onDecrease: () => _stepLimitPrice(
                                          quote,
                                          decimalPlace,
                                          -_priceStep(decimalPlace),
                                        ),
                                        onIncrease: () => _stepLimitPrice(
                                          quote,
                                          decimalPlace,
                                          _priceStep(decimalPlace),
                                        ),
                                      ),
                                      if (pendingValidation.issue != null &&
                                          pendingValidation.issue!.isPriceRule)
                                        _OrderValidationHint(
                                          text: pendingValidation.issue!
                                              .message(l10n),
                                        ),
                                    ],
                                    const Divider(
                                        height: 1,
                                        color: TradeOrderColors.divider),
                                    _InlineDoubleFieldRow(
                                      key: ValueKey(
                                        'sl_${_symbol}_${executionType.name}',
                                      ),
                                      label: l10n.tradeOrderStopLoss,
                                      valueProvider: orderStopLossPriceProvider,
                                      hintText: l10n.tradeOrderNotSet,
                                      decimalPlace: decimalPlace,
                                      resolveLatestPrice: () =>
                                          _latestPrice(quote),
                                      onDecrease: () => _stepStopLossPrice(
                                        quote,
                                        decimalPlace,
                                        -_priceStep(decimalPlace),
                                      ),
                                      onIncrease: () => _stepStopLossPrice(
                                        quote,
                                        decimalPlace,
                                        _priceStep(decimalPlace),
                                      ),
                                    ),
                                    const Divider(
                                        height: 1,
                                        color: TradeOrderColors.divider),
                                    _InlineDoubleFieldRow(
                                      key: ValueKey(
                                        'tp_${_symbol}_${executionType.name}',
                                      ),
                                      label: l10n.tradeOrderTakeProfit,
                                      valueProvider:
                                          orderTakeProfitPriceProvider,
                                      hintText: l10n.tradeOrderNotSet,
                                      decimalPlace: decimalPlace,
                                      resolveLatestPrice: () =>
                                          _latestPrice(quote),
                                      onDecrease: () => _stepTakeProfitPrice(
                                        quote,
                                        decimalPlace,
                                        -_priceStep(decimalPlace),
                                      ),
                                      onIncrease: () => _stepTakeProfitPrice(
                                        quote,
                                        decimalPlace,
                                        _priceStep(decimalPlace),
                                      ),
                                    ),
                                    if (profitLossHint != null)
                                      _OrderValidationHint(
                                        text: profitLossHint,
                                      ),
                                    if (executionType.isInstant) ...[
                                      const Divider(
                                          height: 1,
                                          color: TradeOrderColors.divider),
                                      _InlineIntFieldRow(
                                        key: ValueKey(
                                          'dev_${_symbol}_${executionType.name}',
                                        ),
                                        label: l10n.tradeOrderDeviation,
                                        valueProvider:
                                            orderDeviationPointsProvider,
                                        defaultValue: effectiveDeviation,
                                        suffix: l10n.tradeOrderPointsSuffix,
                                        onDecrease: () => _adjustDeviation(-1),
                                        onIncrease: () => _adjustDeviation(1),
                                      ),
                                    ],
                                    if (executionType.showsPriceAndExpiry) ...[
                                      const Divider(
                                          height: 1,
                                          color: TradeOrderColors.divider),
                                      TradeOrderExpiryField(
                                        key: ValueKey(
                                          'expiry_${_symbol}_${executionType.name}',
                                        ),
                                        label: l10n.tradeOrderExpiry,
                                      ),
                                    ],
                                    const Divider(
                                        height: 1,
                                        color: TradeOrderColors.divider),
                                    _QuoteBar(
                                      bid: quote.bid,
                                      ask: quote.ask,
                                      decimalPlace: decimalPlace,
                                    ),
                                    if (executionType.isInstant)
                                      _BuySellRow(
                                        sellLabel: l10n.historyTradeSell,
                                        buyLabel: l10n.historyTradeBuy,
                                        sellEnabled: sellPlValidation.isValid,
                                        buyEnabled: buyPlValidation.isValid,
                                        sellDisabledHint: sellPlHint,
                                        buyDisabledHint: buyPlHint,
                                        onSell: () => _onPlaceOrder(
                                          l10n,
                                          isBuy: false,
                                        ),
                                        onBuy: () => _onPlaceOrder(
                                          l10n,
                                          isBuy: true,
                                        ),
                                      )
                                    else
                                      _SubmitOrderButton(
                                        label: l10n.tradeOrderSubmit,
                                        color: executionType.accentColor,
                                        enabled: canSubmitPending,
                                        disabledHint: pendingDisabledHint,
                                        onPressed: canSubmitPending
                                            ? () => _onPlaceOrder(
                                                  l10n,
                                                  isBuy: executionType
                                                      .isBuyDirection,
                                                )
                                            : null,
                                      ),
                                    if (_symbol.isNotEmpty) ...[
                                      const Divider(
                                        height: 1,
                                        color: TradeOrderColors.divider,
                                      ),
                                      SizedBox(
                                        height: chartHeight,
                                        child: TradeOrderCandleChart(
                                          key: ValueKey<String>(
                                            'trade_order_chart_$_symbol',
                                          ),
                                          symbol: _symbol,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            _ModifyOrderDisclaimerFooter(
                              text: l10n.tradeOrderModifyDisclaimer(
                                stopLevelPoints,
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('$e', textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () => ref
                                    .read(marketWatchlistProvider.notifier)
                                    .refresh(),
                                child: Text(l10n.retryButton),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _adjustLot(double delta) {
    if (_symbol.isEmpty) return;
    final quote = ref.read(tradeOrderQuoteProvider(_symbol)).valueOrNull;
    final current = ref.read(orderLotSizeProvider) ?? quote?.defaultLot ?? 0.01;
    final next = (current + delta).clamp(0.01, 100.0);
    ref.read(orderLotSizeProvider.notifier).state =
        double.parse(next.toStringAsFixed(2));
  }

  double _priceStep(int decimalPlace) =>
      minPriceMoveForDecimalPlace(decimalPlace);

  double _latestPrice(TradeSymbolQuote quote) {
    if (quote.bid > 0 && quote.ask > 0) {
      return (quote.bid + quote.ask) / 2;
    }
    return quote.ask > 0 ? quote.ask : quote.bid;
  }

  void _stepPriceField(
    TradeSymbolQuote quote,
    int decimalPlace,
    double delta,
    AutoDisposeStateProvider<double?> provider,
  ) {
    final latest = _latestPrice(quote);
    if (latest <= 0) return;
    final current = ref.read(provider);
    final base = current ?? latest;
    final next = roundMarketPrice(
      (base + delta)
          .clamp(minPriceMoveForDecimalPlace(decimalPlace), double.maxFinite),
      decimalPlace,
    );
    ref.read(provider.notifier).state = next;
  }

  void _stepLimitPrice(
    TradeSymbolQuote quote,
    int decimalPlace,
    double delta,
  ) {
    if (ref.read(orderExecutionTypeProvider).isInstant) {
      return;
    }
    _stepPriceField(quote, decimalPlace, delta, orderLimitPriceProvider);
  }

  void _stepStopLossPrice(
    TradeSymbolQuote quote,
    int decimalPlace,
    double delta,
  ) {
    _stepPriceField(quote, decimalPlace, delta, orderStopLossPriceProvider);
  }

  void _stepTakeProfitPrice(
    TradeSymbolQuote quote,
    int decimalPlace,
    double delta,
  ) {
    _stepPriceField(quote, decimalPlace, delta, orderTakeProfitPriceProvider);
  }

  void _adjustDeviation(int delta) {
    final current = ref.read(orderDeviationPointsProvider) ?? 5;
    final next = (current + delta).clamp(1, 9999);
    ref.read(orderDeviationPointsProvider.notifier).state = next;
  }

  void _onTradeMqttResponse(
      AppLocalizations l10n, TradeMqttResponse? response) {
    if (response == null) return;

    switch (response.operationType) {
      case TradeMqttOperationType.tradeBack:
        unawaited(
          finishInstantTradeResponse(
            ref: ref,
            context: context,
            l10n: l10n,
            response: response,
            pendingSymbol: ref.read(tradeInstantOrderPendingProvider),
            clearPending: () => ref
                .read(tradeInstantOrderPendingProvider.notifier)
                .state = null,
          ),
        );
      case TradeMqttOperationType.orderBack:
        unawaited(
          _finishMqttOrder(
            l10n,
            response: response,
            pendingSymbol: ref.read(tradePendingOrderPendingProvider),
            clearPending: () => ref
                .read(tradePendingOrderPendingProvider.notifier)
                .state = null,
          ),
        );
      case TradeMqttOperationType.modifyProfitLossBack:
      case TradeMqttOperationType.orderModifyProfitLossBack:
        _finishModifyProfitLoss(l10n, response);
      case TradeMqttOperationType.closeOrderBack:
        _finishCloseOrder(l10n, response);
      case TradeMqttOperationType.orderRemoveBack:
        _finishRemovePendingOnModifyPage(l10n, response);
      default:
        break;
    }
  }

  void _finishModifyProfitLoss(
    AppLocalizations l10n,
    TradeMqttResponse response,
  ) {
    final pendingId = ref.read(tradeModifyProfitLossPendingProvider);
    if (pendingId == null) return;

    ref.read(tradeModifyProfitLossPendingProvider.notifier).state = null;
    if (!mounted) return;

    final modify = ref.read(tradeOrderModifyContextProvider);
    final infoType = modify?.isPending == true
        ? OrderInfoQueryType.pending
        : OrderInfoQueryType.instant;

    unawaited(
      handleModifyProfitLossMqttResponse(
        ref: ref,
        context: context,
        l10n: l10n,
        response: response,
        orderId: pendingId,
        orderInfoType: infoType,
        onSuccessCleanup: () {
          if (modify != null && modify.isPending) {
            unawaited(ref.read(pendOrderListProvider.notifier).reload());
          }
        },
      ),
    );
  }

  void _finishRemovePendingOnModifyPage(
    AppLocalizations l10n,
    TradeMqttResponse response,
  ) {
    final modify = ref.read(tradeOrderModifyContextProvider);
    if (modify == null || !modify.isPending) return;

    final pendingOrderId = ref.read(tradeRemoveOrderPendingProvider);
    if (pendingOrderId != null) {
      if (modify.orderId != pendingOrderId) return;
      ref.read(tradeRemoveOrderPendingProvider.notifier).state = null;
    }

    if (!mounted) return;

    if (!response.isSuccess) {
      context.showAppMessage(
        tradeResultMessage(l10n, response),
        variant: AppMessageVariant.error,
        duration: AppToast.tradeErrorDuration,
      );
      return;
    }

    ref.read(pendOrderListProvider.notifier).removeById(modify.orderId);
    unawaited(TradeOrderSuccessSound.play());
    leaveTradeOrderPage(context, ref);
  }

  int _stopLevelPointsForSymbol(
    List<MarketQuote>? quotes,
    String symbol,
  ) {
    if (quotes == null || symbol.isEmpty) {
      return kDefaultModifyStopLevelPoints;
    }
    for (final row in quotes) {
      if (row.symbol == symbol) {
        final level = row.variety.stopLossLevel;
        return level > 0 ? level : kDefaultModifyStopLevelPoints;
      }
    }
    return kDefaultModifyStopLevelPoints;
  }

  ModifyProfitLossValidationResult _profitLossValidation({
    required TradeSide side,
    required TradeSymbolQuote quote,
    required int decimalPlace,
    required int stopLevelPoints,
    required double? stopLoss,
    required double? takeProfit,
  }) {
    return ModifyProfitLossValidator.validate(
      side: side,
      bid: quote.bid,
      ask: quote.ask,
      decimalPlace: decimalPlace,
      stopLevelPoints: stopLevelPoints,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
    );
  }

  bool _canSubmitModifyProfitLoss({
    required TradeOrderModifyContext modify,
    required ModifyProfitLossValidationResult validation,
    required double? stopLoss,
    required double? takeProfit,
    required int decimalPlace,
  }) {
    return validation.isValid &&
        ModifyProfitLossValidator.hasProfitLossChanges(
          modify: modify,
          stopLoss: stopLoss,
          takeProfit: takeProfit,
          decimalPlace: decimalPlace,
        );
  }

  String _closeSubmitLabel(AppLocalizations l10n, double floatingProfit) {
    final pnl = TradeFormatters.amount(floatingProfit);
    if (floatingProfit >= 0) {
      return l10n.tradeOrderCloseWithProfit(pnl);
    }
    return l10n.tradeOrderCloseWithLoss(pnl);
  }

  OpenPosition _positionFromCloseModify(TradeOrderModifyContext modify) {
    return OpenPosition(
      id: modify.orderId,
      symbol: modify.symbol,
      side: modify.side,
      volume: modify.volume ?? 0,
      priceFrom: modify.openPrice ?? 0,
      priceTo: 0,
      profit: modify.snapshotProfit,
      margin: 0,
      takeProfit: modify.takeProfit,
      stopLoss: modify.stopLoss,
    );
  }

  Widget _buildClosePositionOrderLayout({
    required AppLocalizations l10n,
    required TradeSymbolQuote quote,
    required TradeOrderModifyContext modify,
    required int decimalPlace,
    required double chartHeight,
  }) {
    final tabState = ref.watch(tradeTabProvider);
    final live = tabState.positionsByOrderId[modify.orderId];
    final floatingProfit = live?.profit ?? modify.snapshotProfit;
    final closeLabel = _closeSubmitLabel(l10n, floatingProfit);
    final effectiveLot = modify.volume ?? quote.defaultLot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _ModifyOrderBanner(text: modify.closeBannerText(l10n)),
                _LotFieldRow(
                  defaultLot: effectiveLot,
                  enabled: false,
                  onDecreaseLarge: () {},
                  onDecreaseSmall: () {},
                  onIncreaseSmall: () {},
                  onIncreaseLarge: () {},
                ),
                const Divider(height: 1, color: TradeOrderColors.divider),
                _InlineDoubleFieldRow(
                  key: ValueKey('close_sl_${modify.orderId}'),
                  label: l10n.tradeOrderStopLoss,
                  valueProvider: orderStopLossPriceProvider,
                  hintText: l10n.tradeOrderNotSet,
                  decimalPlace: decimalPlace,
                  valueColor: TradeOrderColors.sellRed,
                  enabled: false,
                  resolveLatestPrice: () => _latestPrice(quote),
                  onDecrease: () {},
                  onIncrease: () {},
                ),
                const Divider(height: 1, color: TradeOrderColors.divider),
                _InlineDoubleFieldRow(
                  key: ValueKey('close_tp_${modify.orderId}'),
                  label: l10n.tradeOrderTakeProfit,
                  valueProvider: orderTakeProfitPriceProvider,
                  hintText: l10n.tradeOrderNotSet,
                  decimalPlace: decimalPlace,
                  valueColor: TradeOrderColors.primaryBlue,
                  enabled: false,
                  resolveLatestPrice: () => _latestPrice(quote),
                  onDecrease: () {},
                  onIncrease: () {},
                ),
                const Divider(height: 1, color: TradeOrderColors.divider),
                _QuoteBar(
                  bid: quote.bid,
                  ask: quote.ask,
                  decimalPlace: decimalPlace,
                ),
                _SubmitOrderButton(
                  label: closeLabel,
                  color: TradeOrderColors.closeAction,
                  enabled: true,
                  onPressed: () => unawaited(
                    closePosition(
                      ref: ref,
                      context: context,
                      l10n: l10n,
                      position: _positionFromCloseModify(modify),
                    ),
                  ),
                ),
                if (_symbol.isNotEmpty) ...[
                  const Divider(height: 1, color: TradeOrderColors.divider),
                  SizedBox(
                    height: chartHeight,
                    child: TradeOrderCandleChart(
                      key: ValueKey<String>('trade_order_close_chart_$_symbol'),
                      symbol: _symbol,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _finishCloseOrder(AppLocalizations l10n, TradeMqttResponse response) {
    final pendingId = ref.read(tradeCloseOrderPendingProvider);
    if (pendingId == null) return;

    ref.read(tradeCloseOrderPendingProvider.notifier).state = null;
    if (!mounted) return;

    unawaited(
      handleCloseOrderMqttResponse(
        ref: ref,
        context: context,
        l10n: l10n,
        response: response,
        orderId: pendingId,
        onSuccessCleanup: () {
          ref.read(tradeTabProvider.notifier).removePosition(pendingId);
        },
      ),
    );
  }

  Widget _buildModifyPositionOrderLayout({
    required AppLocalizations l10n,
    required TradeSymbolQuote quote,
    required TradeOrderModifyContext modify,
    required int decimalPlace,
    required double chartHeight,
    required List<MarketQuote>? watchlistQuotes,
  }) {
    final stopLoss = ref.watch(orderStopLossPriceProvider);
    final takeProfit = ref.watch(orderTakeProfitPriceProvider);
    final stopLevelPoints =
        _stopLevelPointsForSymbol(watchlistQuotes, modify.symbol);
    final validation = ModifyProfitLossValidator.validate(
      side: modify.side,
      bid: quote.bid,
      ask: quote.ask,
      decimalPlace: decimalPlace,
      stopLevelPoints: stopLevelPoints,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
    );
    final validationHint = validation.issue?.message(
      l10n,
      stopLevelPoints: validation.effectiveStopLevelPoints,
    );
    final canModify = _canSubmitModifyProfitLoss(
      modify: modify,
      validation: validation,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      decimalPlace: decimalPlace,
    );

    final priceText = formatTradePrice(
      modify.openPrice ?? 0,
      decimalPlace: decimalPlace,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _ModifyOrderBanner(
                  text: modify.bannerText(l10n, priceText),
                ),
                _InlineDoubleFieldRow(
                  key: ValueKey('modify_sl_${modify.orderId}'),
                  label: l10n.tradeOrderStopLoss,
                  valueProvider: orderStopLossPriceProvider,
                  hintText: l10n.tradeOrderNotSet,
                  decimalPlace: decimalPlace,
                  valueColor: TradeOrderColors.sellRed,
                  resolveLatestPrice: () => _latestPrice(quote),
                  onDecrease: () => _stepStopLossPrice(
                    quote,
                    decimalPlace,
                    -_priceStep(decimalPlace),
                  ),
                  onIncrease: () => _stepStopLossPrice(
                    quote,
                    decimalPlace,
                    _priceStep(decimalPlace),
                  ),
                ),
                const Divider(height: 1, color: TradeOrderColors.divider),
                _InlineDoubleFieldRow(
                  key: ValueKey('modify_tp_${modify.orderId}'),
                  label: l10n.tradeOrderTakeProfit,
                  valueProvider: orderTakeProfitPriceProvider,
                  hintText: l10n.tradeOrderNotSet,
                  decimalPlace: decimalPlace,
                  valueColor: TradeOrderColors.primaryBlue,
                  resolveLatestPrice: () => _latestPrice(quote),
                  onDecrease: () => _stepTakeProfitPrice(
                    quote,
                    decimalPlace,
                    -_priceStep(decimalPlace),
                  ),
                  onIncrease: () => _stepTakeProfitPrice(
                    quote,
                    decimalPlace,
                    _priceStep(decimalPlace),
                  ),
                ),
                const Divider(height: 1, color: TradeOrderColors.divider),
                _QuoteBar(
                  bid: quote.bid,
                  ask: quote.ask,
                  decimalPlace: decimalPlace,
                ),
                _SubmitOrderButton(
                  label: l10n.tradeOrderModifySubmit,
                  color: TradeOrderColors.sellRed,
                  enabled: canModify,
                  disabledHint: validationHint,
                  onPressed: canModify
                      ? () => unawaited(_onSubmitModify(l10n, modify))
                      : null,
                ),
                if (_symbol.isNotEmpty) ...[
                  const Divider(height: 1, color: TradeOrderColors.divider),
                  SizedBox(
                    height: chartHeight,
                    child: TradeOrderCandleChart(
                      key:
                          ValueKey<String>('trade_order_modify_chart_$_symbol'),
                      symbol: _symbol,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        _ModifyOrderDisclaimerFooter(
          text: l10n.tradeOrderModifyDisclaimer(stopLevelPoints),
        ),
      ],
    );
  }

  Widget _buildModifyPendingOrderLayout({
    required AppLocalizations l10n,
    required TradeSymbolQuote quote,
    required TradeOrderModifyContext modify,
    required int decimalPlace,
    required double chartHeight,
    required List<MarketQuote>? watchlistQuotes,
  }) {
    final stopLoss = ref.watch(orderStopLossPriceProvider);
    final takeProfit = ref.watch(orderTakeProfitPriceProvider);
    final stopLevelPoints =
        _stopLevelPointsForSymbol(watchlistQuotes, modify.symbol);

    final validation = ModifyProfitLossValidator.validate(
      side: modify.side,
      bid: quote.bid,
      ask: quote.ask,
      decimalPlace: decimalPlace,
      stopLevelPoints: stopLevelPoints,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
    );
    final validationHint = validation.issue?.message(
      l10n,
      stopLevelPoints: validation.effectiveStopLevelPoints,
    );
    final canModify = _canSubmitModifyProfitLoss(
      modify: modify,
      validation: validation,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      decimalPlace: decimalPlace,
    );

    final lotText = TradeFormatters.volume(modify.lot ?? quote.defaultLot);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _ModifyOrderBanner(
                  text: modify.bannerText(l10n, lotText),
                ),
                _InlineDoubleFieldRow(
                  key: ValueKey('pending_modify_sl_${modify.orderId}'),
                  label: l10n.tradeOrderStopLoss,
                  valueProvider: orderStopLossPriceProvider,
                  hintText: l10n.tradeOrderNotSet,
                  decimalPlace: decimalPlace,
                  valueColor: TradeOrderColors.sellRed,
                  resolveLatestPrice: () => _latestPrice(quote),
                  onDecrease: () => _stepStopLossPrice(
                    quote,
                    decimalPlace,
                    -_priceStep(decimalPlace),
                  ),
                  onIncrease: () => _stepStopLossPrice(
                    quote,
                    decimalPlace,
                    _priceStep(decimalPlace),
                  ),
                ),
                const Divider(height: 1, color: TradeOrderColors.divider),
                _InlineDoubleFieldRow(
                  key: ValueKey('pending_modify_tp_${modify.orderId}'),
                  label: l10n.tradeOrderTakeProfit,
                  valueProvider: orderTakeProfitPriceProvider,
                  hintText: l10n.tradeOrderNotSet,
                  decimalPlace: decimalPlace,
                  valueColor: TradeOrderColors.primaryBlue,
                  resolveLatestPrice: () => _latestPrice(quote),
                  onDecrease: () => _stepTakeProfitPrice(
                    quote,
                    decimalPlace,
                    -_priceStep(decimalPlace),
                  ),
                  onIncrease: () => _stepTakeProfitPrice(
                    quote,
                    decimalPlace,
                    _priceStep(decimalPlace),
                  ),
                ),
                const Divider(height: 1, color: TradeOrderColors.divider),
                _QuoteBar(
                  bid: quote.bid,
                  ask: quote.ask,
                  decimalPlace: decimalPlace,
                ),
                _ModifyDeleteButtonRow(
                  modifyLabel: l10n.tradeOrderModifySubmit,
                  deleteLabel: l10n.tradeOrderDelete,
                  modifyEnabled: canModify,
                  modifyDisabledHint: validationHint,
                  onModify: canModify
                      ? () => unawaited(_onSubmitModify(l10n, modify))
                      : null,
                  onDelete: () =>
                      unawaited(_onDeletePendingModify(l10n, modify)),
                ),
                if (_symbol.isNotEmpty) ...[
                  const Divider(height: 1, color: TradeOrderColors.divider),
                  SizedBox(
                    height: chartHeight,
                    child: TradeOrderCandleChart(
                      key: ValueKey<String>(
                        'trade_order_modify_pending_chart_$_symbol',
                      ),
                      symbol: _symbol,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        _ModifyOrderDisclaimerFooter(
          text: l10n.tradeOrderModifyDisclaimer(stopLevelPoints),
        ),
      ],
    );
  }

  Future<void> _onDeletePendingModify(
    AppLocalizations l10n,
    TradeOrderModifyContext modify,
  ) async {
    final kind = modify.pendingKind;
    if (kind == null) return;

    await cancelPendingOrder(
      ref: ref,
      context: context,
      l10n: l10n,
      order: PendingOrder(
        id: modify.orderId,
        symbol: modify.symbol,
        kind: kind,
        lot: modify.lot ?? 0.01,
        limitPrice: modify.limitPrice ?? 0,
        currentPrice: 0,
        takeProfit: modify.takeProfit,
        stopLoss: modify.stopLoss,
        createdAt: modify.expiryMs != null
            ? DateTime.fromMillisecondsSinceEpoch(modify.expiryMs!)
                .toIso8601String()
            : '',
      ),
    );
  }

  Future<void> _onSubmitModify(
    AppLocalizations l10n,
    TradeOrderModifyContext modify,
  ) async {
    await submitModifyProfitLoss(
      ref: ref,
      context: context,
      l10n: l10n,
      modify: modify,
      takeProfit: ref.read(orderTakeProfitPriceProvider),
      stopLoss: ref.read(orderStopLossPriceProvider),
    );
  }

  Future<void> _finishMqttOrder(
    AppLocalizations l10n, {
    required TradeMqttResponse response,
    required String? pendingSymbol,
    required VoidCallback clearPending,
  }) {
    return handlePlaceOrderMqttResponse(
      ref: ref,
      context: context,
      l10n: l10n,
      response: response,
      pendingSymbol: pendingSymbol,
      clearPending: clearPending,
      orderInfoType: OrderInfoQueryType.pending,
    );
  }

  void _onPlaceOrder(AppLocalizations l10n, {required bool isBuy}) {
    final executionType = ref.read(orderExecutionTypeProvider);
    if (executionType.isInstant) {
      unawaited(_placeInstantOrder(l10n, isBuy: isBuy));
      return;
    }

    unawaited(_placePendingOrder(l10n));
  }

  Future<void> _placePendingOrder(AppLocalizations l10n) async {
    if (_symbol.isEmpty) return;

    final executionType = ref.read(orderExecutionTypeProvider);
    final quote = ref.read(tradeOrderQuoteProvider(_symbol)).valueOrNull;
    if (quote == null) return;

    final lot = ref.read(orderLotSizeProvider) ?? quote.defaultLot;
    final limitPrice = ref.read(orderLimitPriceProvider);
    final expiryAt = ref.read(orderExpiryAtProvider);
    final validation = PendingOrderValidator.validate(
      executionType: executionType,
      lot: lot,
      limitPrice: limitPrice,
      expiryAt: expiryAt,
      bid: quote.bid,
      ask: quote.ask,
    );
    if (!validation.isValid) {
      final issue = validation.issue;
      if (issue != null && mounted) {
        context.showAppMessage(issue.message(l10n));
      }
      return;
    }

    final watchlistQuotes = ref.read(marketWatchlistProvider).valueOrNull;
    final decimalPlace = decimalPlaceForSymbol(watchlistQuotes, _symbol);
    final stopLevelPoints =
        _stopLevelPointsForSymbol(watchlistQuotes, _symbol);
    final stopLoss = ref.read(orderStopLossPriceProvider);
    final takeProfit = ref.read(orderTakeProfitPriceProvider);
    final plValidation = _profitLossValidation(
      side: executionType.tradeSide,
      quote: quote,
      decimalPlace: decimalPlace,
      stopLevelPoints: stopLevelPoints,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
    );
    if (!plValidation.isValid) {
      final issue = plValidation.issue;
      if (issue != null && mounted) {
        context.showAppMessage(
          issue.message(
            l10n,
            stopLevelPoints: plValidation.effectiveStopLevelPoints,
          ),
        );
      }
      return;
    }

    final mqtt = ref.read(tradeMqttClientProvider);
    if (!mqtt.isConnected) {
      context.showAppMessage(
        l10n.tradeOrderMqttOffline,
        variant: AppMessageVariant.error,
      );
      return;
    }

    final command = TradeMqttCommands.pendingOrder(
      symbol: _symbol,
      lot: lot,
      price: limitPrice!,
      executionType: executionType,
      takeProfit: ref.read(orderTakeProfitPriceProvider),
      stopLoss: ref.read(orderStopLossPriceProvider),
      expiryMs: expiryAt!.millisecondsSinceEpoch,
    );

    ref.read(tradePendingOrderPendingProvider.notifier).state = _symbol;
    mqtt.publishCommand(command);

    // if (!mounted) return;
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(l10n.tradeOrderSubmitting),
    //     duration: const Duration(seconds: 2),
    //   ),
    // );
  }

  Future<void> _placeInstantOrder(
    AppLocalizations l10n, {
    required bool isBuy,
  }) async {
    final quote = ref.read(tradeOrderQuoteProvider(_symbol)).valueOrNull;
    final lot = ref.read(orderLotSizeProvider) ?? quote?.defaultLot ?? 0.01;

    if (quote != null) {
      final watchlistQuotes = ref.read(marketWatchlistProvider).valueOrNull;
      final decimalPlace = decimalPlaceForSymbol(watchlistQuotes, _symbol);
      final stopLevelPoints =
          _stopLevelPointsForSymbol(watchlistQuotes, _symbol);
      final stopLoss = ref.read(orderStopLossPriceProvider);
      final takeProfit = ref.read(orderTakeProfitPriceProvider);
      final plValidation = _profitLossValidation(
        side: isBuy ? TradeSide.buy : TradeSide.sell,
        quote: quote,
        decimalPlace: decimalPlace,
        stopLevelPoints: stopLevelPoints,
        stopLoss: stopLoss,
        takeProfit: takeProfit,
      );
      if (!plValidation.isValid) {
        final issue = plValidation.issue;
        if (issue != null && mounted) {
          context.showAppMessage(
            issue.message(
              l10n,
              stopLevelPoints: plValidation.effectiveStopLevelPoints,
            ),
          );
        }
        return;
      }
    }

    await submitInstantTrade(
      ref: ref,
      context: context,
      l10n: l10n,
      symbol: _symbol,
      lot: lot,
      isBuy: isBuy,
      takeProfit: ref.read(orderTakeProfitPriceProvider),
      stopLoss: ref.read(orderStopLossPriceProvider),
    );
  }

  /// Bottom sheets render above the route overlay; force light theme so text
  /// stays dark when [appThemeModeProvider] is dark (e.g. opened from chart tab).
  Widget _tradeOrderSheetTheme(Widget child) {
    return Theme(
      data: AppTheme.light(),
      child: child,
    );
  }

  Future<void> _showSymbolSheet(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    List<MarketQuote> quotes;
    final cached = ref.read(marketWatchlistProvider);
    if (cached.hasValue && cached.requireValue.isNotEmpty) {
      quotes = cached.requireValue;
    } else {
      try {
        quotes = await ref.read(marketWatchlistProvider.future);
      } on Object {
        if (!context.mounted) return;
        context.showAppMessage(l10n.marketWatchlistEmpty);
        return;
      }
    }

    if (!context.mounted || quotes.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return _tradeOrderSheetTheme(
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.tradeOrderPickSymbol,
                    style: AppFonts.barlowCondensedBold(
                      fontSize: 16,
                      color: TradeOrderColors.title,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: quotes.length,
                    itemBuilder: (context, index) {
                      final quote = quotes[index];
                      final selected = _symbol == quote.symbol;
                      return ListTile(
                        title: Text(
                          quote.symbol,
                          style: AppFonts.barlowCondensedBold(
                            fontSize: 16,
                            color: TradeOrderColors.title,
                          ),
                        ),
                        trailing: selected
                            ? const Icon(
                                Icons.check,
                                color: TradeOrderColors.primaryBlue,
                              )
                            : null,
                        onTap: () {
                          if (_symbol != quote.symbol) {
                            setState(() {
                              _symbol = quote.symbol;
                              _clearOrderInputs();
                            });
                          }
                          Navigator.of(ctx).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModifyOrderDisclaimerFooter extends StatelessWidget {
  const _ModifyOrderDisclaimerFooter({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: TradeOrderColors.divider)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          height: 1.45,
          color: TradeOrderColors.subtitle,
        ),
      ),
    );
  }
}

class _ModifyOrderBanner extends StatelessWidget {
  const _ModifyOrderBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: TradeOrderColors.divider)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: TradeOrderColors.title,
        ),
      ),
    );
  }
}

class _OrderAppBar extends StatelessWidget {
  const _OrderAppBar({
    required this.symbol,
    required this.onBack,
    this.onPickSymbol,
  });

  final String symbol;
  final VoidCallback onBack;
  final VoidCallback? onPickSymbol;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: TradeOrderColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: TradeOrderColors.primaryBlue,
            ),
          ),
          Expanded(
            child: onPickSymbol == null
                ? Center(
                    child: Text(
                      symbol,
                      style: AppFonts.tradeOrderTitle(),
                    ),
                  )
                : InkWell(
                    onTap: onPickSymbol,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          symbol,
                          style: AppFonts.tradeOrderTitle(),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppFonts.tradeSummaryValueColor,
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _LotFieldRow extends ConsumerStatefulWidget {
  const _LotFieldRow({
    required this.defaultLot,
    required this.onDecreaseLarge,
    required this.onDecreaseSmall,
    required this.onIncreaseSmall,
    required this.onIncreaseLarge,
    this.enabled = true,
  });

  final double defaultLot;
  final VoidCallback onDecreaseLarge;
  final VoidCallback onDecreaseSmall;
  final VoidCallback onIncreaseSmall;
  final VoidCallback onIncreaseLarge;
  final bool enabled;

  @override
  ConsumerState<_LotFieldRow> createState() => _LotFieldRowState();
}

class _LotFieldRowState extends ConsumerState<_LotFieldRow> {
  static const double _minLot = 0.01;
  static const double _maxLot = 100.0;

  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  double get _displayLot => ref.read(orderLotSizeProvider) ?? widget.defaultLot;

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _commitLot(_controller.text);
    }
  }

  void _syncController(double lot) {
    final text = lot.toStringAsFixed(2);
    if (_controller.text != text) {
      _controller.text = text;
    }
  }

  double _normalizeLot(double value) {
    final clamped = value.clamp(_minLot, _maxLot);
    return double.parse(clamped.toStringAsFixed(2));
  }

  void _commitLot(String raw) {
    final trimmed = raw.trim();
    final parsed = double.tryParse(trimmed);
    final next = _normalizeLot(parsed ?? _displayLot);
    ref.read(orderLotSizeProvider.notifier).state = next;
    _syncController(next);
  }

  void _onTextChanged(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final parsed = double.tryParse(trimmed);
    if (parsed != null && parsed > 0) {
      ref.read(orderLotSizeProvider.notifier).state = parsed;
    }
  }

  void _onStep(VoidCallback step) {
    step();
    _syncController(_normalizeLot(_displayLot));
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(orderLotSizeProvider);
    final lot = _displayLot;
    if (!_focusNode.hasFocus) {
      _syncController(lot);
    }

    return IgnorePointer(
      ignoring: !widget.enabled,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.55,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              _StepButton(
                label: '-0.1',
                enabled: widget.enabled,
                onTap: () => _onStep(widget.onDecreaseLarge),
              ),
              _StepButton(
                label: '-0.01',
                enabled: widget.enabled,
                onTap: () => _onStep(widget.onDecreaseSmall),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  readOnly: !widget.enabled,
                  enableInteractiveSelection: widget.enabled,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: TradeOrderColors.title,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: InputBorder.none,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: _onTextChanged,
                  onSubmitted: _commitLot,
                  onEditingComplete: () => _commitLot(_controller.text),
                ),
              ),
              _StepButton(
                label: '+0.01',
                enabled: widget.enabled,
                onTap: () => _onStep(widget.onIncreaseSmall),
              ),
              _StepButton(
                label: '+0.1',
                enabled: widget.enabled,
                onTap: () => _onStep(widget.onIncreaseLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onTap : null,
      style: TextButton.styleFrom(
        foregroundColor: TradeOrderColors.primaryBlue,
        minimumSize: const Size(48, 40),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: TradeOrderColors.primaryBlue,
        ),
      ),
    );
  }
}

class _InlineDoubleFieldRow extends ConsumerStatefulWidget {
  const _InlineDoubleFieldRow({
    super.key,
    required this.label,
    required this.valueProvider,
    required this.resolveLatestPrice,
    required this.onDecrease,
    required this.onIncrease,
    required this.hintText,
    required this.decimalPlace,
    this.valueColor,
    this.enabled = true,
  });

  final String label;
  final AutoDisposeStateProvider<double?> valueProvider;
  final double Function() resolveLatestPrice;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final String hintText;
  final int decimalPlace;
  final Color? valueColor;
  final bool enabled;

  @override
  ConsumerState<_InlineDoubleFieldRow> createState() =>
      _InlineDoubleFieldRowState();
}

class _InlineDoubleFieldRowState extends ConsumerState<_InlineDoubleFieldRow> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
    _focusNode.addListener(_onFocusChange);
  }

  bool _isInputEmpty() {
    if (ref.read(widget.valueProvider) != null) return false;
    return _controller.text.trim().isEmpty;
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus || !_isInputEmpty()) return;
    final latest = widget.resolveLatestPrice();
    if (latest <= 0) return;
    final rounded = roundMarketPrice(latest, widget.decimalPlace);
    ref.read(widget.valueProvider.notifier).state = rounded;
    _syncController(rounded);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _syncController(double? value) {
    final text = value == null
        ? ''
        : formatTradePrice(value, decimalPlace: widget.decimalPlace);
    if (_controller.text != text) {
      _controller.text = text;
    }
  }

  void _onTextChanged(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      ref.read(widget.valueProvider.notifier).state = null;
      return;
    }
    final parsed = double.tryParse(trimmed);
    if (parsed != null && parsed > 0) {
      ref.read(widget.valueProvider.notifier).state = parsed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(widget.valueProvider);
    if (!_focusNode.hasFocus) {
      _syncController(value);
    }

    void onStep(VoidCallback step) {
      step();
      final stepped = ref.read(widget.valueProvider);
      if (stepped != null) {
        _syncController(stepped);
      }
    }

    return IgnorePointer(
      ignoring: !widget.enabled,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.55,
        child: _FieldRowShell(
          label: widget.label,
          steppersEnabled: widget.enabled,
          onDecrease: () => onStep(widget.onDecrease),
          onIncrease: () => onStep(widget.onIncrease),
          center: TextField(
            controller: _controller,
            focusNode: _focusNode,
            readOnly: !widget.enabled,
            enableInteractiveSelection: widget.enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.valueColor ?? TradeOrderColors.title,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
              border: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.valueColor ?? TradeOrderColors.fieldHint,
              ),
            ),
            onChanged: widget.enabled ? _onTextChanged : null,
          ),
        ),
      ),
    );
  }
}

class _InlineIntFieldRow extends ConsumerStatefulWidget {
  const _InlineIntFieldRow({
    super.key,
    required this.label,
    required this.valueProvider,
    required this.defaultValue,
    required this.suffix,
    required this.onDecrease,
    required this.onIncrease,
    this.enabled = true,
  });

  final String label;
  final AutoDisposeStateProvider<int?> valueProvider;
  final int defaultValue;
  final String suffix;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final bool enabled;

  @override
  ConsumerState<_InlineIntFieldRow> createState() => _InlineIntFieldRowState();
}

class _InlineIntFieldRowState extends ConsumerState<_InlineIntFieldRow> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _syncController(int value) {
    final text = '$value';
    if (_controller.text != text) {
      _controller.text = text;
    }
  }

  void _onTextChanged(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      ref.read(widget.valueProvider.notifier).state = widget.defaultValue;
      return;
    }
    final parsed = int.tryParse(trimmed);
    if (parsed != null && parsed >= 1) {
      ref.read(widget.valueProvider.notifier).state = parsed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(widget.valueProvider) ?? widget.defaultValue;
    if (!_focusNode.hasFocus) {
      _syncController(value);
    }

    return IgnorePointer(
      ignoring: !widget.enabled,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.55,
        child: _FieldRowShell(
          label: widget.label,
          steppersEnabled: widget.enabled,
          onDecrease: widget.onDecrease,
          onIncrease: widget.onIncrease,
          center: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  readOnly: !widget.enabled,
                  enableInteractiveSelection: widget.enabled,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TradeOrderColors.title,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 6),
                    border: InputBorder.none,
                  ),
                  onChanged: widget.enabled ? _onTextChanged : null,
                ),
              ),
              Text(
                widget.suffix,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TradeOrderColors.title,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldRowShell extends StatelessWidget {
  const _FieldRowShell({
    required this.label,
    required this.center,
    this.onDecrease,
    this.onIncrease,
    this.steppersEnabled = true,
  });

  final String label;
  final Widget center;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final bool steppersEnabled;

  static const double _labelWidth = 44;
  static const double _labelGap = 28;

  @override
  Widget build(BuildContext context) {
    final hasSteppers = onDecrease != null && onIncrease != null;
    final steppersActive = steppersEnabled && hasSteppers;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: _labelWidth,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: TradeOrderColors.title,
              ),
            ),
          ),
          const SizedBox(width: _labelGap),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: hasSteppers
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _RoundIconButton(
                          icon: Icons.remove,
                          onTap: steppersActive ? onDecrease : null,
                          enabled: steppersActive,
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 108,
                          child: center,
                        ),
                        const SizedBox(width: 10),
                        _RoundIconButton(
                          icon: Icons.add,
                          onTap: steppersActive ? onIncrease : null,
                          enabled: steppersActive,
                        ),
                      ],
                    )
                  : center,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? const Color(0xFFF2F2F7) : const Color(0xFFFAFAFA),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(
            icon,
            size: 16,
            color: enabled
                ? TradeOrderColors.primaryBlue
                : TradeOrderColors.fieldHint,
          ),
        ),
      ),
    );
  }
}

class _QuoteBar extends StatelessWidget {
  const _QuoteBar({
    required this.bid,
    required this.ask,
    required this.decimalPlace,
  });

  final double bid;
  final double ask;
  final int decimalPlace;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TradeOrderColors.quoteBarBg,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: QuotePriceText.orderQuote(
              price: bid,
              color: TradeOrderColors.title,
              decimalPlace: decimalPlace,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: QuotePriceText.orderQuote(
              price: ask,
              color: TradeOrderColors.sellRed,
              decimalPlace: decimalPlace,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderValidationHint extends StatelessWidget {
  const _OrderValidationHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          text,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 12,
            color: TradeOrderColors.sellRed,
          ),
        ),
      ),
    );
  }
}

class _SubmitOrderButton extends StatelessWidget {
  const _SubmitOrderButton({
    required this.label,
    required this.color,
    required this.enabled,
    this.disabledHint,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final bool enabled;
  final String? disabledHint;
  final VoidCallback? onPressed;

  static const Color _disabledBg = Color(0xFFBDBDBD);

  @override
  Widget build(BuildContext context) {
    final bg = enabled ? color : _disabledBg;

    return Material(
      color: bg,
      child: InkWell(
        onTap: enabled
            ? onPressed
            : () {
                final hint = disabledHint;
                if (hint == null || hint.isEmpty) return;
                context.showAppMessage(hint);
              },
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: enabled ? Colors.white : const Color(0xFF757575),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModifyDeleteButtonRow extends StatelessWidget {
  const _ModifyDeleteButtonRow({
    required this.modifyLabel,
    required this.deleteLabel,
    required this.modifyEnabled,
    required this.onDelete,
    this.modifyDisabledHint,
    this.onModify,
  });

  final String modifyLabel;
  final String deleteLabel;
  final bool modifyEnabled;
  final String? modifyDisabledHint;
  final VoidCallback? onModify;
  final VoidCallback onDelete;

  static const Color _disabledBg = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SubmitOrderButton(
            label: modifyLabel,
            color: modifyEnabled ? TradeOrderColors.primaryBlue : _disabledBg,
            enabled: modifyEnabled,
            disabledHint: modifyDisabledHint,
            onPressed: onModify,
          ),
        ),
        Expanded(
          child: Material(
            color: TradeOrderColors.sellRed,
            child: InkWell(
              onTap: onDelete,
              child: SizedBox(
                height: 48,
                child: Center(
                  child: Text(
                    deleteLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BuySellRow extends StatelessWidget {
  const _BuySellRow({
    required this.sellLabel,
    required this.buyLabel,
    required this.sellEnabled,
    required this.buyEnabled,
    this.sellDisabledHint,
    this.buyDisabledHint,
    required this.onSell,
    required this.onBuy,
  });

  final String sellLabel;
  final String buyLabel;
  final bool sellEnabled;
  final bool buyEnabled;
  final String? sellDisabledHint;
  final String? buyDisabledHint;
  final VoidCallback onSell;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BuySellSideButton(
            label: sellLabel,
            color: TradeOrderColors.sellRed,
            enabled: sellEnabled,
            disabledHint: sellDisabledHint,
            onTap: onSell,
          ),
        ),
        Expanded(
          child: _BuySellSideButton(
            label: buyLabel,
            color: TradeOrderColors.primaryBlue,
            enabled: buyEnabled,
            disabledHint: buyDisabledHint,
            onTap: onBuy,
          ),
        ),
      ],
    );
  }
}

class _BuySellSideButton extends StatelessWidget {
  const _BuySellSideButton({
    required this.label,
    required this.color,
    required this.enabled,
    this.disabledHint,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool enabled;
  final String? disabledHint;
  final VoidCallback onTap;

  static const Color _disabledBg = Color(0xFFBDBDBD);
  static const Color _disabledText = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    final bg = enabled ? color : _disabledBg;

    return Material(
      color: bg,
      child: InkWell(
        onTap: enabled
            ? onTap
            : () {
                final hint = disabledHint;
                if (hint == null || hint.isEmpty) return;
                context.showAppMessage(hint);
              },
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: enabled ? Colors.white : _disabledText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
