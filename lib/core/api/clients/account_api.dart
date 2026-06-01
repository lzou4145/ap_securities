import 'package:ap_securities/core/api/api_client_base.dart';
import 'package:ap_securities/core/api/app_api_paths.dart';
import 'package:ap_securities/core/api/models/api_models_account.dart';

/// APP-api / 账户
class AccountApi extends ApiClientBase {
  AccountApi(super.http);

  /// 获取账号资金
  /// `GET /api/account/getWalletsTrade`
  Future<AccountWalletsTrade> getWalletsTrade() async {
    return http.getData(
      AppApiPaths.account_getWalletsTrade,
      fromJson: AccountWalletsTrade.fromJson,
    );
  }
}
