import 'package:ap_securities/features/market/domain/market_price_format.dart';
import 'package:ap_securities/features/trade/domain/trade_order_modify_context.dart';
import 'package:ap_securities/features/trade/domain/trade_side.dart';
import 'package:ap_securities/l10n/l10n.dart';

/// Fallback when variety [`stop_loss_level`] is 0.
const int kDefaultModifyStopLevelPoints = 16;

enum ModifyProfitLossValidationIssue {
  quoteUnavailable,
  buyStopLossMustBeBelowBid,
  buyTakeProfitMustBeAboveAsk,
  sellStopLossMustBeAboveAsk,
  sellTakeProfitMustBeBelowBid,
}

class ModifyProfitLossValidationResult {
  const ModifyProfitLossValidationResult.valid({
    required this.effectiveStopLevelPoints,
  })  : issue = null,
        isValid = true;

  const ModifyProfitLossValidationResult.invalid(
    this.issue, {
    required this.effectiveStopLevelPoints,
  }) : isValid = false;

  final bool isValid;
  final ModifyProfitLossValidationIssue? issue;

  /// Points used for distance checks — same number shown in hints.
  final int effectiveStopLevelPoints;
}

extension ModifyProfitLossValidationIssueX on ModifyProfitLossValidationIssue {
  String message(AppLocalizations l10n, {required int stopLevelPoints}) =>
      switch (this) {
        ModifyProfitLossValidationIssue.quoteUnavailable =>
          l10n.tradeOrderQuoteUnavailable,
        ModifyProfitLossValidationIssue.buyStopLossMustBeBelowBid =>
          l10n.tradeOrderModifyBuyStopLossRule(stopLevelPoints),
        ModifyProfitLossValidationIssue.buyTakeProfitMustBeAboveAsk =>
          l10n.tradeOrderModifyBuyTakeProfitRule(stopLevelPoints),
        ModifyProfitLossValidationIssue.sellStopLossMustBeAboveAsk =>
          l10n.tradeOrderModifySellStopLossRule(stopLevelPoints),
        ModifyProfitLossValidationIssue.sellTakeProfitMustBeBelowBid =>
          l10n.tradeOrderModifySellTakeProfitRule(stopLevelPoints),
      };
}

abstract final class ModifyProfitLossValidator {
  static ModifyProfitLossValidationResult validate({
    required TradeSide side,
    required double bid,
    required double ask,
    required int decimalPlace,
    required int stopLevelPoints,
    required double? stopLoss,
    required double? takeProfit,
  }) {
    final level =
        stopLevelPoints > 0 ? stopLevelPoints : kDefaultModifyStopLevelPoints;

    if (bid <= 0 || ask <= 0) {
      return ModifyProfitLossValidationResult.invalid(
        ModifyProfitLossValidationIssue.quoteUnavailable,
        effectiveStopLevelPoints: level,
      );
    }

    final minDistance = level * minPriceMoveForDecimalPlace(decimalPlace);

    if (stopLoss != null && stopLoss > 0) {
      final sl = roundMarketPrice(stopLoss, decimalPlace);
      final slIssue = switch (side) {
        TradeSide.buy => sl <= bid - minDistance
            ? null
            : ModifyProfitLossValidationIssue.buyStopLossMustBeBelowBid,
        TradeSide.sell => sl >= ask + minDistance
            ? null
            : ModifyProfitLossValidationIssue.sellStopLossMustBeAboveAsk,
      };
      if (slIssue != null) {
        return ModifyProfitLossValidationResult.invalid(
          slIssue,
          effectiveStopLevelPoints: level,
        );
      }
    }

    if (takeProfit != null && takeProfit > 0) {
      final tp = roundMarketPrice(takeProfit, decimalPlace);
      final tpIssue = switch (side) {
        TradeSide.buy => tp >= ask + minDistance
            ? null
            : ModifyProfitLossValidationIssue.buyTakeProfitMustBeAboveAsk,
        TradeSide.sell => tp <= bid - minDistance
            ? null
            : ModifyProfitLossValidationIssue.sellTakeProfitMustBeBelowBid,
      };
      if (tpIssue != null) {
        return ModifyProfitLossValidationResult.invalid(
          tpIssue,
          effectiveStopLevelPoints: level,
        );
      }
    }

    return ModifyProfitLossValidationResult.valid(
      effectiveStopLevelPoints: level,
    );
  }

  /// True when SL/TP differ from values on [modify] (entry state → button stays disabled).
  static bool hasProfitLossChanges({
    required TradeOrderModifyContext modify,
    required double? stopLoss,
    required double? takeProfit,
    required int decimalPlace,
  }) {
    double? normalized(double? value) {
      if (value == null || value <= 0) return null;
      return roundMarketPrice(value, decimalPlace);
    }

    final initialSl =
        normalized(modify.stopLoss > 0 ? modify.stopLoss : null);
    final initialTp =
        normalized(modify.takeProfit > 0 ? modify.takeProfit : null);
    final currentSl = normalized(stopLoss);
    final currentTp = normalized(takeProfit);
    return currentSl != initialSl || currentTp != initialTp;
  }
}
