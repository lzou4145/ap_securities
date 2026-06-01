import 'package:ap_securities/core/api/json/json_read.dart';
import 'package:ap_securities/core/api/models/api_models_common.dart';

class AccountBrief {
  const AccountBrief({required this.accountId, required this.accountName});

  factory AccountBrief.fromJson(Map<String, dynamic> json) {
    return AccountBrief(
      accountId: JsonRead.asInt(json['account_id']),
      accountName: JsonRead.asString(json['account_name']),
    );
  }

  final int accountId;
  final String accountName;
}

class SingleTraderWallet {
  const SingleTraderWallet({
    required this.accountId,
    required this.followWalletsTradeAmount,
    required this.followCommissionRate,
  });

  factory SingleTraderWallet.fromJson(Map<String, dynamic> json) {
    return SingleTraderWallet(
      accountId: JsonRead.asInt(json['account_id']),
      followWalletsTradeAmount:
          JsonRead.asString(json['follow_wallets_trade_amount']),
      followCommissionRate: JsonRead.asInt(json['follow_commission_rate']),
    );
  }

  final int accountId;
  final String followWalletsTradeAmount;
  final int followCommissionRate;
}

class SingleTraderItem {
  const SingleTraderItem({
    required this.singleAccountId,
    required this.createdAt,
    required this.singleAccount,
    this.singleAccountWalletTrade,
  });

  factory SingleTraderItem.fromJson(Map<String, dynamic> json) {
    final walletRaw = json['single_account_wallet_trade'] ?? json['wallets_trade'];
    return SingleTraderItem(
      singleAccountId: JsonRead.asInt(json['single_account_id']),
      createdAt: JsonRead.asString(json['created_at']),
      singleAccount:
          AccountBrief.fromJson(JsonRead.map(json['single_account'])),
      singleAccountWalletTrade: walletRaw is Map
          ? SingleTraderWallet.fromJson(JsonRead.map(walletRaw))
          : null,
    );
  }

  final int singleAccountId;
  final String createdAt;
  final AccountBrief singleAccount;
  final SingleTraderWallet? singleAccountWalletTrade;
}

class RankItem {
  const RankItem({
    required this.accountId,
    required this.daysAmount,
    required this.followWalletsTradeAmount,
    required this.followCommissionRate,
    required this.account,
  });

  factory RankItem.fromJson(Map<String, dynamic> json) {
    final wallet = _rankWalletFromJson(json);

    return RankItem(
      accountId: JsonRead.asInt(json['account_id']),
      daysAmount: JsonRead.asString(json['days_amount']),
      followWalletsTradeAmount: json['follow_wallets_trade_amount'] != null
          ? JsonRead.asString(json['follow_wallets_trade_amount'])
          : (wallet?.followWalletsTradeAmount ?? ''),
      followCommissionRate: json['follow_commission_rate'] != null
          ? JsonRead.asInt(json['follow_commission_rate'])
          : (wallet?.followCommissionRate ?? 0),
      account: AccountBrief.fromJson(JsonRead.map(json['account'])),
    );
  }

  /// Rank list nests copy-trade fields under `wallets_trade` (not login `amount`).
  static SingleTraderWallet? _rankWalletFromJson(Map<String, dynamic> json) {
    for (final key in ['wallets_trade', 'single_account_wallet_trade']) {
      final raw = json[key];
      if (raw is Map) {
        return SingleTraderWallet.fromJson(JsonRead.map(raw));
      }
    }
    return null;
  }

  final int accountId;

  /// Period profit from API (`days_amount`).
  final String daysAmount;

  /// Copy-trade balance limit (`follow_wallets_trade_amount`).
  final String followWalletsTradeAmount;

  /// Commission rate percent (`follow_commission_rate`, e.g. 15 = 15%).
  final int followCommissionRate;
  final AccountBrief account;
}

class FollowItem {
  const FollowItem({
    required this.followAccountId,
    required this.createdAt,
    required this.followAccount,
  });

  factory FollowItem.fromJson(Map<String, dynamic> json) {
    return FollowItem(
      followAccountId: JsonRead.asInt(json['follow_account_id']),
      createdAt: JsonRead.asString(json['created_at']),
      followAccount:
          AccountBrief.fromJson(JsonRead.map(json['follow_account'])),
    );
  }

  final int followAccountId;
  final String createdAt;
  final AccountBrief followAccount;
}

class SingleConfig {
  const SingleConfig({
    required this.followWalletsTradeAmount,
    required this.followCommissionRate,
  });

  factory SingleConfig.fromJson(Object? json) {
    final map = JsonRead.map(json);
    return SingleConfig(
      followWalletsTradeAmount:
          JsonRead.asString(map['follow_wallets_trade_amount']),
      followCommissionRate: JsonRead.asInt(map['follow_commission_rate']),
    );
  }

  final String followWalletsTradeAmount;
  final int followCommissionRate;
}

List<LabelValueOption> parseLabelValueOptions(Object? json) =>
    parseListOrEmpty(json, LabelValueOption.fromJson);

List<SingleTraderItem> parseSingleTraderList(Object? json) =>
    parseListOrEmpty(json, SingleTraderItem.fromJson);

List<RankItem> parseRankList(Object? json) =>
    parseListOrEmpty(json, RankItem.fromJson);

List<FollowItem> parseFollowList(Object? json) =>
    parseListOrEmpty(json, FollowItem.fromJson);
