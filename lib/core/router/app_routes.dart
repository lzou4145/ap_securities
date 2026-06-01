/// Typed route paths for the app router and deep links.
abstract final class AppRoutes {
  static const String startup = '/startup';
  static const String login = '/login';
  static const String market = '/market';
  static const String marketAddSymbols = '/market/add-symbols';

  static String marketAddSymbolsCategory(String type) =>
      '/market/add-symbols/$type';

  static String marketSymbolDetail(String symbol) =>
      '/market/symbol/${Uri.encodeComponent(symbol)}';
  static const String chart = '/chart';
  static const String trade = '/trade';
  static const String tradeOrder = '/trade/order';

  static String tradeOrderWithSymbol(String symbol) =>
      '$tradeOrder?symbol=${Uri.encodeComponent(symbol)}';

  static const String tradeOrderSuccess = '/trade/order/success';

  static String tradeOrderSuccessWithOrderId(
    String orderId, {
    required int type,
    String variant = 'place',
  }) =>
      '$tradeOrderSuccess?order_id=${Uri.encodeComponent(orderId)}&type=$type&variant=$variant';
  static const String portfolio = '/portfolio';
  static const String profile = '/profile';
  static const String profileAccounts = '/profile/accounts';
  static const String profileAddAccount = '/profile/accounts/add';
  static const String profileLanguage = '/profile/language';
  static const String profileBackendLink = '/profile/backend-link';
  static const String profileAnnouncements = '/profile/announcements';
  static const String profilePersonalizedTrading =
      '/profile/personalized-trading';
  static const String profileFollowTrader = '/profile/personalized-trading/follow';
  static const String profileSingleProviderSettings =
      '/profile/personalized-trading/single-settings';
  static const String profileFollowDetails =
      '/profile/personalized-trading/follow-details';

  static String profileFollowTraderWithAccount({
    required int singleAccountId,
    String? accountName,
    String? daysAmount,
    String? followWalletsTradeAmount,
    int? followCommissionRate,
  }) {
    final params = <String, String>{
      'single_account_id': '$singleAccountId',
      if (accountName != null && accountName.trim().isNotEmpty)
        'name': accountName.trim(),
      if (daysAmount != null && daysAmount.trim().isNotEmpty)
        'profit': daysAmount.trim(),
      if (followWalletsTradeAmount != null &&
          followWalletsTradeAmount.trim().isNotEmpty)
        'follow_balance': followWalletsTradeAmount.trim(),
      if (followCommissionRate != null && followCommissionRate > 0)
        'commission': '$followCommissionRate',
    };
    return Uri(
      path: profileFollowTrader,
      queryParameters: params,
    ).toString();
  }

  static String profileAnnouncementDetail(String id) =>
      '$profileAnnouncements/$id';
}
