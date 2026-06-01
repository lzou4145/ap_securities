import 'package:ap_securities/core/api/clients/account_api.dart';
import 'package:ap_securities/core/api/clients/auth_api.dart';
import 'package:ap_securities/core/api/clients/follow_api.dart';
import 'package:ap_securities/core/api/clients/market_api.dart';
import 'package:ap_securities/core/api/clients/notice_api.dart';
import 'package:ap_securities/core/api/clients/order_api.dart';
import 'package:ap_securities/core/network/app_http_client.dart';

/// Unified entry for all APP-api HTTP calls (OpenAPI `APP-api` folder).
class AppApi {
  AppApi(AppHttpClient http)
      : auth = AuthApi(http),
        market = MarketApi(http),
        order = OrderApi(http),
        account = AccountApi(http),
        follow = FollowApi(http),
        notice = NoticeApi(http);

  final AuthApi auth;
  final MarketApi market;
  final OrderApi order;
  final AccountApi account;
  final FollowApi follow;
  final NoticeApi notice;
}
