import 'package:ap_securities/core/api/json/json_read.dart';
import 'package:ap_securities/core/api/models/api_models_common.dart';

class OrderHistoryTotal {
  const OrderHistoryTotal({
    required this.totalRechargeNum,
    required this.totalWithdrawNum,
    required this.totalOpenNum,
    required this.totalCloseNum,
    required this.totalProfit,
    required this.totalBalance,
  });

  factory OrderHistoryTotal.fromJson(Object? json) {
    final map = JsonRead.map(json);
    return OrderHistoryTotal(
      totalRechargeNum: JsonRead.asString(map['total_recharge_num']),
      totalWithdrawNum: JsonRead.asString(map['total_withdraw_num']),
      totalOpenNum: JsonRead.asString(map['total_open_num']),
      totalCloseNum: JsonRead.asString(map['total_close_num']),
      totalProfit: JsonRead.asString(map['total_profit']),
      totalBalance: JsonRead.asString(map['total_balance']),
    );
  }

  final String totalRechargeNum;
  final String totalWithdrawNum;
  final String totalOpenNum;
  final String totalCloseNum;
  final String totalProfit;
  final String totalBalance;
}

class OrderHistoryVariety {
  const OrderHistoryVariety({
    required this.id,
    required this.code,
    required this.name,
  });

  factory OrderHistoryVariety.fromJson(Object? json) {
    final map = JsonRead.map(json);
    return OrderHistoryVariety(
      id: JsonRead.asInt(map['id']),
      code: JsonRead.asString(map['code']),
      name: JsonRead.asString(map['name']),
    );
  }

  final int id;
  final String code;
  final String name;
}

class OrderHistoryWalletTrade {
  const OrderHistoryWalletTrade({
    required this.accountId,
    required this.lever,
  });

  factory OrderHistoryWalletTrade.fromJson(Object? json) {
    final map = JsonRead.map(json);
    return OrderHistoryWalletTrade(
      accountId: JsonRead.asInt(map['account_id']),
      lever: JsonRead.asInt(map['lever']),
    );
  }

  final int accountId;
  final int lever;
}

/// Closed order row from `GET /api/order/historyList`.
class OrderHistoryItem {
  const OrderHistoryItem({
    required this.orderId,
    required this.userId,
    required this.accountId,
    required this.varietyId,
    required this.num,
    required this.status,
    required this.buildPrice,
    required this.closePrice,
    required this.amount,
    required this.type,
    required this.createdAt,
    required this.bail,
    required this.takeProfit,
    required this.stopLoss,
    required this.actType,
    required this.buildFee,
    required this.closeAt,
    required this.feeInventory,
    required this.profitLoss,
    this.variety,
    this.walletTrade,
  });

  factory OrderHistoryItem.fromJson(Map<String, dynamic> json) {
    return OrderHistoryItem(
      orderId: JsonRead.asString(json['order_id']),
      userId: JsonRead.asInt(json['user_id']),
      accountId: JsonRead.asInt(json['account_id']),
      varietyId: JsonRead.asInt(json['variety_id']),
      num: JsonRead.asString(json['num']),
      status: JsonRead.asInt(json['status']),
      buildPrice: JsonRead.asString(json['build_price']),
      closePrice: JsonRead.asString(json['close_price']),
      amount: JsonRead.asString(json['amount']),
      type: JsonRead.asInt(json['type']),
      createdAt: JsonRead.asString(json['created_at']),
      bail: JsonRead.asString(json['bail']),
      takeProfit: JsonRead.asString(json['take_profit']),
      stopLoss: JsonRead.asString(json['stop_loss']),
      actType: JsonRead.asInt(json['act_type']),
      buildFee: JsonRead.asString(json['build_fee']),
      closeAt: JsonRead.asString(json['close_at']),
      feeInventory: JsonRead.asString(json['fee_inventory']),
      profitLoss: JsonRead.asString(json['profit_loss']),
      variety: json['variety'] == null
          ? null
          : OrderHistoryVariety.fromJson(json['variety']),
      walletTrade: json['wallet_trade'] == null
          ? null
          : OrderHistoryWalletTrade.fromJson(json['wallet_trade']),
    );
  }

  final String orderId;
  final int userId;
  final int accountId;
  final int varietyId;
  final String num;
  final int status;
  final String buildPrice;
  final String closePrice;
  final String amount;
  final int type;
  final String createdAt;
  final String bail;
  final String takeProfit;
  final String stopLoss;
  final int actType;
  final String buildFee;
  final String closeAt;
  final String feeInventory;
  final String profitLoss;
  final OrderHistoryVariety? variety;
  final OrderHistoryWalletTrade? walletTrade;
}

/// Order detail from `GET /api/order/getOrderInfoByOrderId`.
class OrderInfo {
  const OrderInfo({
    required this.id,
    required this.uuid,
    required this.orderId,
    required this.varietyId,
    required this.userId,
    required this.accountId,
    required this.num,
    required this.buildPrice,
    required this.pendPrice,
    required this.closePrice,
    required this.buildFee,
    required this.pointDiff,
    required this.amount,
    required this.bail,
    required this.status,
    required this.type,
    required this.singleAccountId,
    required this.singleFee,
    required this.createdAt,
    required this.updatedAt,
    required this.takeProfit,
    required this.stopLoss,
    required this.actType,
    required this.feeInventory,
    this.pendType,
    this.deletedAt,
    this.closeAt,
    this.profitLoss,
    this.variety,
  });

  factory OrderInfo.fromJson(Object? json) {
    final map = JsonRead.map(json);
    return OrderInfo(
      id: JsonRead.asInt(map['id']),
      uuid: JsonRead.asString(map['uuid']),
      orderId: JsonRead.asString(map['order_id']),
      varietyId: JsonRead.asInt(map['variety_id']),
      userId: JsonRead.asInt(map['user_id']),
      accountId: JsonRead.asInt(map['account_id']),
      num: JsonRead.asString(map['num']),
      buildPrice: JsonRead.asString(map['build_price']),
      pendPrice: JsonRead.asString(
        map['pend_price'] ?? map['price'] ?? map['limit_price'],
      ),
      closePrice: JsonRead.asString(map['close_price']),
      buildFee: JsonRead.asString(map['build_fee']),
      pointDiff: JsonRead.asInt(map['point_diff']),
      amount: JsonRead.asString(map['amount']),
      bail: JsonRead.asString(map['bail']),
      status: JsonRead.asInt(map['status']),
      type: JsonRead.asInt(map['type']),
      singleAccountId: JsonRead.asInt(map['single_account_id']),
      singleFee: JsonRead.asString(map['single_fee']),
      createdAt: JsonRead.asString(map['created_at']),
      updatedAt: JsonRead.asString(map['updated_at']),
      deletedAt: JsonRead.asStringOrNull(map['deleted_at']),
      takeProfit: JsonRead.asString(map['take_profit']),
      stopLoss: JsonRead.asString(map['stop_loss']),
      actType: JsonRead.asInt(map['act_type']),
      pendType: JsonRead.asIntOrNull(map['pend_type']),
      closeAt: JsonRead.asStringOrNull(map['close_at']),
      feeInventory: JsonRead.asString(map['fee_inventory']),
      profitLoss: JsonRead.asStringOrNull(map['profit_loss']),
      variety: map['variety'] == null
          ? null
          : OrderHistoryVariety.fromJson(map['variety']),
    );
  }

  final int id;
  final String uuid;
  final String orderId;
  final int varietyId;
  final int userId;
  final int accountId;
  final String num;
  final String buildPrice;
  final String pendPrice;
  final String closePrice;
  final String buildFee;
  final int pointDiff;
  final String amount;
  final String bail;
  final int status;
  final int type;
  final int singleAccountId;
  final String singleFee;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String takeProfit;
  final String stopLoss;
  final int actType;
  final int? pendType;
  final String? closeAt;
  final String feeInventory;
  final String? profitLoss;
  final OrderHistoryVariety? variety;
}

class PendOrderItem {
  const PendOrderItem({this.raw = const {}});

  factory PendOrderItem.fromJson(Map<String, dynamic> json) {
    return PendOrderItem(raw: json);
  }

  final Map<String, dynamic> raw;
}

class FundFlowRecord {
  const FundFlowRecord({this.raw = const {}});

  factory FundFlowRecord.fromJson(Map<String, dynamic> json) {
    return FundFlowRecord(raw: json);
  }

  final Map<String, dynamic> raw;
}

PaginatedResponse<OrderHistoryItem> parseOrderHistoryPage(Object? json) =>
    PaginatedResponse.fromJson(json, OrderHistoryItem.fromJson);

PaginatedResponse<PendOrderItem> parsePendOrderPage(Object? json) =>
    PaginatedResponse.fromJson(json, PendOrderItem.fromJson);

PaginatedResponse<FundFlowRecord> parseFundFlowPage(Object? json) =>
    PaginatedResponse.fromJson(json, FundFlowRecord.fromJson);
