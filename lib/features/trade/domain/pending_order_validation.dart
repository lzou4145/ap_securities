import 'package:ap_securities/features/trade/domain/order_execution_type.dart';
import 'package:ap_securities/l10n/l10n.dart';

enum PendingOrderValidationIssue {
  lotTooSmall,
  priceRequired,
  expiryRequired,
  expiryNotFuture,
  quoteUnavailable,
  buyLimitPriceMustBeBelowAsk,
  sellLimitPriceMustBeAboveBid,
  buyStopPriceMustBeAboveAsk,
  sellStopPriceMustBeBelowBid,
}

class PendingOrderValidationResult {
  const PendingOrderValidationResult.valid() : issue = null, isValid = true;

  const PendingOrderValidationResult.invalid(this.issue) : isValid = false;

  final bool isValid;
  final PendingOrderValidationIssue? issue;
}

extension PendingOrderValidationIssueX on PendingOrderValidationIssue {
  String message(AppLocalizations l10n) => switch (this) {
        PendingOrderValidationIssue.lotTooSmall => l10n.tradeOrderLotTooSmall,
        PendingOrderValidationIssue.priceRequired =>
          l10n.tradeOrderPriceRequired,
        PendingOrderValidationIssue.expiryRequired =>
          l10n.tradeOrderExpiryRequired,
        PendingOrderValidationIssue.expiryNotFuture =>
          l10n.tradeOrderExpiryMustBeFuture,
        PendingOrderValidationIssue.quoteUnavailable =>
          l10n.tradeOrderQuoteUnavailable,
        PendingOrderValidationIssue.buyLimitPriceMustBeBelowAsk =>
          l10n.tradeOrderBuyLimitPriceRule,
        PendingOrderValidationIssue.sellLimitPriceMustBeAboveBid =>
          l10n.tradeOrderSellLimitPriceRule,
        PendingOrderValidationIssue.buyStopPriceMustBeAboveAsk =>
          l10n.tradeOrderBuyStopPriceRule,
        PendingOrderValidationIssue.sellStopPriceMustBeBelowBid =>
          l10n.tradeOrderSellStopPriceRule,
      };

  bool get isPriceRule => switch (this) {
        PendingOrderValidationIssue.buyLimitPriceMustBeBelowAsk ||
        PendingOrderValidationIssue.sellLimitPriceMustBeAboveBid ||
        PendingOrderValidationIssue.buyStopPriceMustBeAboveAsk ||
        PendingOrderValidationIssue.sellStopPriceMustBeBelowBid =>
          true,
        _ => false,
      };
}

abstract final class PendingOrderValidator {
  static PendingOrderValidationResult validate({
    required OrderExecutionType executionType,
    required double lot,
    required double? limitPrice,
    required DateTime? expiryAt,
    required double bid,
    required double ask,
  }) {
    if (lot < 0.01) {
      return const PendingOrderValidationResult.invalid(
        PendingOrderValidationIssue.lotTooSmall,
      );
    }

    if (limitPrice == null || limitPrice <= 0) {
      return const PendingOrderValidationResult.invalid(
        PendingOrderValidationIssue.priceRequired,
      );
    }

    if (expiryAt == null) {
      return const PendingOrderValidationResult.invalid(
        PendingOrderValidationIssue.expiryRequired,
      );
    }

    final expiryMinute = DateTime(
      expiryAt.year,
      expiryAt.month,
      expiryAt.day,
      expiryAt.hour,
      expiryAt.minute,
    );
    final nowMinute = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      DateTime.now().hour,
      DateTime.now().minute,
    );
    if (!expiryMinute.isAfter(nowMinute)) {
      return const PendingOrderValidationResult.invalid(
        PendingOrderValidationIssue.expiryNotFuture,
      );
    }

    if (bid <= 0 || ask <= 0) {
      return const PendingOrderValidationResult.invalid(
        PendingOrderValidationIssue.quoteUnavailable,
      );
    }

    final priceIssue = switch (executionType) {
      OrderExecutionType.buyLimit =>
        limitPrice < ask
            ? null
            : PendingOrderValidationIssue.buyLimitPriceMustBeBelowAsk,
      OrderExecutionType.sellLimit =>
        limitPrice > bid
            ? null
            : PendingOrderValidationIssue.sellLimitPriceMustBeAboveBid,
      OrderExecutionType.buyStop =>
        limitPrice > ask
            ? null
            : PendingOrderValidationIssue.buyStopPriceMustBeAboveAsk,
      OrderExecutionType.sellStop =>
        limitPrice < bid
            ? null
            : PendingOrderValidationIssue.sellStopPriceMustBeBelowBid,
      OrderExecutionType.instant => null,
    };

    if (priceIssue != null) {
      return PendingOrderValidationResult.invalid(priceIssue);
    }

    return const PendingOrderValidationResult.valid();
  }
}
