import 'package:ap_securities/features/trade/domain/open_position.dart';
import 'package:ap_securities/features/trade/domain/order_execution_type.dart';
import 'package:ap_securities/features/trade/domain/pending_order.dart';
import 'package:ap_securities/features/trade/domain/trade_side.dart';
import 'package:ap_securities/l10n/l10n.dart';

enum OrderModifyMode {
  position,
  pending,
  close,
}

/// Trade order screen — modify open position or pending order.
class TradeOrderModifyContext {
  const TradeOrderModifyContext({
    required this.mode,
    required this.orderId,
    required this.symbol,
    required this.side,
    this.openPrice,
    this.volume,
    this.takeProfit = 0,
    this.stopLoss = 0,
    this.pendingKind,
    this.limitPrice,
    this.lot,
    this.expiryMs,
    this.snapshotProfit = 0,
  });

  final OrderModifyMode mode;
  final String orderId;
  final String symbol;
  final TradeSide side;
  final double? openPrice;
  final double? volume;
  final double takeProfit;
  final double stopLoss;
  final PendingOrderKind? pendingKind;
  final double? limitPrice;
  final double? lot;
  final int? expiryMs;
  final double snapshotProfit;

  bool get isPending => mode == OrderModifyMode.pending;

  bool get isPosition => mode == OrderModifyMode.position;

  bool get isClose => mode == OrderModifyMode.close;

  OrderExecutionType? get executionType => pendingKind?.executionType;

  factory TradeOrderModifyContext.fromPosition(OpenPosition position) {
    return TradeOrderModifyContext(
      mode: OrderModifyMode.position,
      orderId: position.id,
      symbol: position.symbol,
      side: position.side,
      openPrice: position.priceFrom,
      volume: position.volume,
      takeProfit: position.takeProfit,
      stopLoss: position.stopLoss,
      snapshotProfit: position.profit,
    );
  }

  factory TradeOrderModifyContext.fromPositionClose(OpenPosition position) {
    return TradeOrderModifyContext(
      mode: OrderModifyMode.close,
      orderId: position.id,
      symbol: position.symbol,
      side: position.side,
      openPrice: position.priceFrom,
      volume: position.volume,
      takeProfit: position.takeProfit,
      stopLoss: position.stopLoss,
      snapshotProfit: position.profit,
    );
  }

  factory TradeOrderModifyContext.fromPendingOrder(PendingOrder order) {
    return TradeOrderModifyContext(
      mode: OrderModifyMode.pending,
      orderId: order.id,
      symbol: order.symbol,
      side: order.side,
      pendingKind: order.kind,
      limitPrice: order.limitPrice,
      lot: order.lot,
      takeProfit: order.takeProfit,
      stopLoss: order.stopLoss,
      expiryMs: _parseExpiryMs(order.createdAt),
    );
  }

  String sideWireLabel() => side == TradeSide.buy ? 'buy' : 'sell';

  String bannerText(AppLocalizations l10n, String formattedPriceOrLot) {
    if (isClose) {
      return closeBannerText(l10n);
    }
    if (isPending) {
      return l10n.tradeOrderModifyPendingBanner(
        orderId,
        pendingKind!.kindLabel(l10n),
        formattedPriceOrLot,
      );
    }
    return l10n.tradeOrderModifyBanner(
      orderId,
      side == TradeSide.buy ? 'buy' : 'sell',
      formattedPriceOrLot,
    );
  }

  String closeBannerText(AppLocalizations l10n) {
    final sideLabel = side == TradeSide.buy ? 'buy' : 'sell';
    final vol = (volume ?? lot ?? 0).toStringAsFixed(2);
    return l10n.tradeOrderCloseBanner(orderId, sideLabel, vol);
  }

  static int? _parseExpiryMs(String createdAt) {
    if (createdAt.isEmpty) return null;
    final parsed = DateTime.tryParse(createdAt);
    return parsed?.millisecondsSinceEpoch;
  }
}

extension PendingOrderKindLabels on PendingOrderKind {
  OrderExecutionType get executionType => switch (this) {
        PendingOrderKind.buyLimit => OrderExecutionType.buyLimit,
        PendingOrderKind.sellLimit => OrderExecutionType.sellLimit,
        PendingOrderKind.buyStop => OrderExecutionType.buyStop,
        PendingOrderKind.sellStop => OrderExecutionType.sellStop,
      };

  String kindLabel(AppLocalizations l10n) => switch (this) {
        PendingOrderKind.buyLimit => l10n.tradePendingBuyLimit,
        PendingOrderKind.sellLimit => l10n.tradePendingSellLimit,
        PendingOrderKind.buyStop => l10n.tradePendingBuyStop,
        PendingOrderKind.sellStop => l10n.tradePendingSellStop,
      };
}
