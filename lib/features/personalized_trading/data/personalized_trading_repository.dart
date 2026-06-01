import 'package:ap_securities/core/api/app_api.dart';
import 'package:ap_securities/core/api/models/api_models_follow.dart';
import 'package:ap_securities/features/personalized_trading/domain/leaderboard_rank_page.dart';
import 'package:ap_securities/features/personalized_trading/domain/rank_list_params.dart';

class PersonalizedTradingRepository {
  PersonalizedTradingRepository(this._api);

  final AppApi _api;

  Future<LeaderboardRankPageData> fetchRankList({
    required String tradingTimeKey,
    required String rankingMethodKey,
    String? accountId,
  }) async {
    final trimmedAccount = accountId?.trim();
    final ranks = await _api.follow.getRankList(
      timeType: RankListParams.timeType(tradingTimeKey),
      rankType: RankListParams.rankType(rankingMethodKey),
      accountId: trimmedAccount == null || trimmedAccount.isEmpty
          ? ""
          : trimmedAccount,
    );
    return LeaderboardRankPageData(
      updatedAt: DateTime.now(),
      ranks: ranks,
    );
  }

  Future<void> setFollow({
    required int singleAccountId,
    required double lot,
    required int followStatus,
  }) {
    return _api.follow.setFollow(
      singleAccountId: singleAccountId.toString(),
      num: lot.toStringAsFixed(2),
      followStatus: followStatus.toString(),
    );
  }

  Future<List<SingleTraderItem>> getSingleList() => _api.follow.getSingleList();

  Future<SingleConfig> getSingleConfig() => _api.follow.getSingleConfig();

  Future<void> setSingleConfig({
    required String followWalletsTradeAmount,
    required int followCommissionRate,
  }) {
    return _api.follow.setSingleConfig(
      followWalletsTradeAmount: followWalletsTradeAmount,
      followCommissionRate: followCommissionRate,
    );
  }

  Future<void> delFollow({required int singleAccountId}) {
    return _api.follow.delFollow(singleAccountId.toString());
  }
}
