import 'dart:async';

import 'package:ap_securities/core/api/models/api_models_order.dart';
import 'package:ap_securities/core/network/api_exception.dart';
import 'package:ap_securities/core/theme/app_fonts.dart';
import 'package:ap_securities/features/trade/data/order_info_display.dart';
import 'package:ap_securities/features/trade/domain/trade_order_success_content.dart';
import 'package:ap_securities/features/trade/domain/trade_order_success_variant.dart';
import 'package:ap_securities/features/trade/presentation/trade_order_colors.dart';
import 'package:ap_securities/features/trade/presentation/trade_order_success_sound.dart';
import 'package:ap_securities/features/trade/providers/trade_order_modify_provider.dart';
import 'package:ap_securities/features/trade/providers/trade_order_success_providers.dart';
import 'package:ap_securities/features/trade/trade_order_success_navigation.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TradeOrderSuccessPage extends ConsumerStatefulWidget {
  const TradeOrderSuccessPage({
    required this.orderId,
    required this.infoType,
    this.variant = TradeOrderSuccessVariant.place,
    super.key,
  });

  final String orderId;
  final int infoType;
  final TradeOrderSuccessVariant variant;

  @override
  ConsumerState<TradeOrderSuccessPage> createState() =>
      _TradeOrderSuccessPageState();
}

class _TradeOrderSuccessPageState extends ConsumerState<TradeOrderSuccessPage> {
  static const Color _pageGrey = Color(0xFFF2F2F7);
  var _successSoundPlayed = false;

  TradeOrderInfoQuery get _infoParams =>
      (orderId: widget.orderId, type: widget.infoType);

  void _tryPlaySuccessSound(AsyncValue<OrderInfo> next) {
    if (next.isLoading) {
      _successSoundPlayed = false;
      return;
    }
    if (_successSoundPlayed || !next.hasValue || next.hasError) return;
    _successSoundPlayed = true;
    unawaited(TradeOrderSuccessSound.play());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Order page may stay mounted under this route; clear modify after success
      // is visible so the placement UI does not flash during transition.
      ref.read(tradeOrderModifyContextProvider.notifier).state = null;
      _tryPlaySuccessSound(ref.read(tradeOrderInfoProvider(_infoParams)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final infoAsync = ref.watch(tradeOrderInfoProvider(_infoParams));

    ref.listen(
      tradeOrderInfoProvider(_infoParams),
      (_, next) => _tryPlaySuccessSound(next),
    );
    final symbol = infoAsync.maybeWhen(
      data: OrderInfoDisplay.symbol,
      orElse: () => '',
    );

    void exitToTradeTab() => exitTradeOrderSuccessToRoot(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        exitToTradeTab();
      },
      child: Scaffold(
        backgroundColor: _pageGrey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          foregroundColor: TradeOrderColors.primaryBlue,
          automaticallyImplyLeading: true,
          leading: IconButton(
            onPressed: exitToTradeTab,
            icon: const Icon(Icons.arrow_back_ios, size: 20),
          ),
          centerTitle: true,
          title: Text(
            symbol,
            style: AppFonts.barlowCondensedBold(
              fontSize: 17,
              color: TradeOrderColors.title,
              height: 1.2,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                onPressed: exitToTradeTab,
                style: IconButton.styleFrom(
                  backgroundColor: TradeOrderColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  minimumSize: const Size(40, 40),
                  fixedSize: const Size(40, 40),
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.check, size: 22),
              ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              child: infoAsync.when(
                loading: () => const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => _ErrorBody(
                  message: _orderInfoErrorMessage(l10n, e),
                  onRetry: () => ref.invalidate(
                    tradeOrderInfoProvider(_infoParams),
                  ),
                  retryLabel: l10n.retryButton,
                ),
                data: (info) => _SuccessBody(
                  data: widget.variant == TradeOrderSuccessVariant.close
                      ? TradeOrderSuccessContent.fromOrderInfoForClose(
                          info,
                          l10n,
                        )
                      : TradeOrderSuccessContent.fromOrderInfo(info, l10n),
                  l10n: l10n,
                  variant: widget.variant,
                ),
              ),
            ),
            const Expanded(child: ColoredBox(color: _pageGrey)),
          ],
        ),
      ),
    );
  }
}

String _orderInfoErrorMessage(AppLocalizations l10n, Object error) {
  if (error is ApiException) {
    final text = error.message.trim();
    if (text.isNotEmpty) return text;
  }
  return l10n.loginFailedSnackbar;
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({
    required this.data,
    required this.l10n,
    required this.variant,
  });

  final TradeOrderSuccessContent data;
  final AppLocalizations l10n;
  final TradeOrderSuccessVariant variant;

  bool get _isModify => variant == TradeOrderSuccessVariant.modify;

  bool get _isClose => variant == TradeOrderSuccessVariant.close;

  bool get _showsProfitLoss =>
      (_isModify || _isClose) &&
      data.formattedStopLoss != null &&
      data.formattedTakeProfit != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppFonts.barlowCondensedBold(
              fontSize: 17,
              height: 1.35,
              color: TradeOrderColors.title,
            ),
            children: [
              TextSpan(text: '#${data.orderId} '),
              TextSpan(
                text: '${data.tradeModeLabel} ${data.lot}',
                style: AppFonts.barlowCondensedBold(
                  fontSize: 17,
                  height: 1.35,
                  color: data.tradeModeColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppFonts.barlowCondensedBold(
              fontSize: 20,
              height: 1.35,
              color: TradeOrderColors.title,
            ),
            children: [
              TextSpan(text: '${data.symbol} at '),
              TextSpan(
                text: data.price,
                style: AppFonts.dinStyle(
                  fontSize: 20,
                  height: 1.35,
                  color: TradeOrderColors.title,
                ),
              ),
            ],
          ),
        ),
        if (_showsProfitLoss) ...[
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppFonts.barlowCondensedBold(
                fontSize: 16,
                height: 1.35,
                color: TradeOrderColors.title,
              ),
              children: [
                const TextSpan(text: 'sl: '),
                TextSpan(
                  text: data.formattedStopLoss,
                  style: AppFonts.dinStyle(
                    fontSize: 16,
                    height: 1.35,
                    color: TradeOrderColors.title,
                  ),
                ),
                const TextSpan(text: ' tp: '),
                TextSpan(
                  text: data.formattedTakeProfit,
                  style: AppFonts.dinStyle(
                    fontSize: 16,
                    height: 1.35,
                    color: TradeOrderColors.title,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (_isClose && data.formattedClosePrice != null)
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppFonts.barlowCondensedBold(
                fontSize: 16,
                height: 1.35,
                color: TradeOrderColors.title,
              ),
              children: [
                TextSpan(text: l10n.tradeOrderClosedAt(data.lot)),
                TextSpan(
                  text: data.formattedClosePrice,
                  style: AppFonts.dinStyle(
                    fontSize: 16,
                    height: 1.35,
                    color: TradeOrderColors.title,
                  ),
                ),
              ],
            ),
          )
        else if (!_isClose)
          Text(
            _isModify
                ? l10n.tradeOrderModifySubmit
                : l10n.tradeOrderSuccessStatus,
            style: AppFonts.barlowCondensedBold(
              fontSize: 16,
              height: 1.35,
              color: TradeOrderColors.title,
            ),
          ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.onRetry,
    required this.retryLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppFonts.barlowCondensedBold(
            fontSize: 15,
            height: 1.35,
            color: TradeOrderColors.title,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: Text(retryLabel)),
      ],
    );
  }
}
