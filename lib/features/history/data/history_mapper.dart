import 'package:ap_securities/core/api/models/api_models_order.dart';
import 'package:ap_securities/features/history/domain/history_period.dart';
import 'package:ap_securities/features/history/domain/trade_history_record.dart';

abstract final class HistoryMapper {
  static HistorySummary summaryFromTotal(OrderHistoryTotal total) {
    return HistorySummary(
      profit: _dbl(total.totalProfit),
      credit: 0,
      deposit: _dbl(total.totalRechargeNum),
      withdrawal: _dbl(total.totalWithdrawNum),
      balance: _dbl(total.totalBalance),
    );
  }

  static TradeHistoryRecord fromApi(OrderHistoryItem item) {
    return TradeHistoryRecord(
      id: item.orderId,
      symbol: item.variety?.code.isNotEmpty == true
          ? item.variety!.code
          : item.variety?.name ?? '',
      side: item.type == 2 ? TradeSide.sell : TradeSide.buy,
      volume: _dbl(item.num),
      openPrice: _dbl(item.buildPrice),
      closePrice: _dbl(item.closePrice),
      closedAt: _parseDateTime(item.closeAt) ??
          _parseDateTime(item.createdAt) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      profit: _dbl(item.profitLoss),
      takeProfit: _dbl(item.takeProfit),
      stopLoss: _dbl(item.stopLoss),
      fee: _dbl(item.buildFee),
      overnightFee: _dbl(item.feeInventory),
    );
  }

  static DateTime? _parseDateTime(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text.replaceFirst(' ', 'T'));
  }

  static double _dbl(String raw) => double.tryParse(raw.trim()) ?? 0;
}
