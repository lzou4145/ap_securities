import 'package:ap_securities/core/api/api_client_base.dart';
import 'package:ap_securities/core/api/app_api_paths.dart';
import 'package:ap_securities/core/api/models/api_models_common.dart';
import 'package:ap_securities/core/api/models/api_models_market.dart';

/// APP-api / 行情
class MarketApi extends ApiClientBase {
  MarketApi(super.http);

  /// 获取默认合约品种列表
  /// `GET /api/market/getDefAccountVarietyList`
  Future<VarietyGroupMap> getDefAccountVarietyList() async {
    return http.getData(
      AppApiPaths.market_getDefAccountVarietyList,
      fromJson: VarietyGroupMap.fromJson,
    );
  }

  /// 合约品种列表
  /// `GET /api/market/varietyList`
  Future<List<Variety>> getVarietyList(String? type, String? code) async {
    return http.getData(
      AppApiPaths.market_varietyList,
      fromJson: parseVarietyList,
      queryParameters:
          ApiClientBase.query(<String, dynamic>{'type': type, 'code': code}),
    );
  }

  /// 按名称模糊查询合约品种
  /// `GET /api/market/varietyFuzzy`
  Future<List<Variety>> getVarietyFuzzy(String? name) async {
    return http.getData(
      AppApiPaths.market_varietyFuzzy,
      fromJson: parseVarietyList,
      queryParameters: ApiClientBase.query(<String, dynamic>{'name': name}),
    );
  }

  /// 添加账号合约品种
  /// `POST /api/market/addAccountVariety`
  Future<void> addAccountVariety(String? varietyId) async {
    return http.postFormData(
      AppApiPaths.market_addAccountVariety,
      fromJson: parseVoid,
      data: ApiClientBase.form(<String, dynamic>{'variety_id': varietyId}),
    );
  }

  /// 获取账号合约品种列表
  /// `GET /api/market/getAccountVarietyList`
  Future<VarietyGroupMap> getAccountVarietyList() async {
    return http.getData(
      AppApiPaths.market_getAccountVarietyList,
      fromJson: VarietyGroupMap.fromJson,
    );
  }

  /// 删除账号合约品种
  /// `POST /api/market/delAccountVariety`
  Future<void> delAccountVariety(String? varietyIds) async {
    return http.postFormData(
      AppApiPaths.market_delAccountVariety,
      fromJson: parseVoid,
      data: ApiClientBase.form(<String, dynamic>{'variety_ids': varietyIds}),
    );
  }

  /// 设置账号合约品种排序
  /// `POST /api/market/setAccountVarietySort`
  Future<void> setAccountVarietySort(String? sortJson) async {
    return http.postFormData(
      AppApiPaths.market_setAccountVarietySort,
      fromJson: parseVoid,
      data: ApiClientBase.form(<String, dynamic>{'sort_json': sortJson}),
    );
  }
}
