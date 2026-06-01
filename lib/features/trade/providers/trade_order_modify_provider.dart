import 'package:ap_securities/features/trade/domain/trade_order_modify_context.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Set before navigating to [TradeOrderPage] for SL/TP modify.
final tradeOrderModifyContextProvider =
    StateProvider<TradeOrderModifyContext?>((ref) => null);

/// Order id awaiting [TradeMqttOperationType.modifyProfitLossBack].
final tradeModifyProfitLossPendingProvider = StateProvider<String?>((ref) => null);
