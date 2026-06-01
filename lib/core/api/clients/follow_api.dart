import 'package:ap_securities/core/api/api_client_base.dart';
import 'package:ap_securities/core/api/app_api_paths.dart';
import 'package:ap_securities/core/api/models/api_models_common.dart';
import 'package:ap_securities/core/api/models/api_models_follow.dart';

/// APP-api / 跟单
class FollowApi extends ApiClientBase {
  FollowApi(super.http);

  /// 获取倍数选项
  /// `GET /api/market/multipleNumOptions`
  Future<List<LabelValueOption>> getMultipleNumOptions() async {
    return http.getData(
      AppApiPaths.market_multipleNumOptions,
      fromJson: parseLabelValueOptions,
    );
  }

  /// 获取带单用户列表
  /// `GET /api/market/getSingleList`
  Future<List<SingleTraderItem>> getSingleList() async {
    return http.getData(
      AppApiPaths.market_getSingleList,
      fromJson: parseSingleTraderList,
    );
  }

  /// 获取用户排名列表
  /// `GET /api/market/getRankList`
  Future<List<RankItem>> getRankList({
    required String timeType,
    required String rankType,
    String? accountId,
  }) async {
    return http.getData(
      AppApiPaths.market_getRankList,
      fromJson: parseRankList,
      queryParameters: ApiClientBase.query(<String, dynamic>{
        'time_type': timeType,
        'rank_type': rankType,
        'account_id': accountId,
      }),
    );
  }

  /// 设置跟单用户
  /// `POST /api/market/setFollow`
  Future<void> setFollow({
    required String singleAccountId,
    required String num,
    required String followStatus,
  }) async {
    return http.postFormData(
      AppApiPaths.market_setFollow,
      fromJson: parseVoid,
      data: ApiClientBase.form(<String, dynamic>{
        'single_account_id': singleAccountId,
        'num': num,
        'follow_status': followStatus,
      }),
    );
  }

  /// 取消跟单用户
  /// `POST /api/market/delFollow`
  Future<void> delFollow(String? singleAccountId) async {
    return http.postFormData(
      AppApiPaths.market_delFollow,
      fromJson: parseVoid,
      data: ApiClientBase.form(
          <String, dynamic>{'single_account_id': singleAccountId}),
    );
  }

  /// 设置带单用户配置
  /// `POST /api/market/setSingleConfig`
  Future<void> setSingleConfig({
    required String followWalletsTradeAmount,
    required int followCommissionRate,
  }) async {
    return http.postFormData(
      AppApiPaths.market_setSingleConfig,
      fromJson: parseVoid,
      data: ApiClientBase.form(<String, dynamic>{
        'follow_wallets_trade_amount': followWalletsTradeAmount,
        'follow_commission_rate': followCommissionRate,
      }),
    );
  }

  /// 获取带单用户配置
  /// `GET /api/market/getSingleConfig`
  Future<SingleConfig> getSingleConfig() async {
    return http.getData(
      AppApiPaths.market_getSingleConfig,
      fromJson: SingleConfig.fromJson,
    );
  }

  /// 获取跟单用户列表
  /// `GET /api/market/getFollowList`
  Future<List<FollowItem>> getFollowList() async {
    return http.getData(
      AppApiPaths.market_getFollowList,
      fromJson: parseFollowList,
    );
  }
}
