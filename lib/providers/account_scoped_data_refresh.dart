import 'package:ap_securities/features/announcements/providers/announcements_providers.dart';
import 'package:ap_securities/features/history/providers/history_providers.dart';
import 'package:ap_securities/features/market/providers/market_providers.dart';
import 'package:ap_securities/features/market/providers/market_watchlist_notifier.dart';
import 'package:ap_securities/features/personalized_trading/providers/personalized_trading_providers.dart';
import 'package:ap_securities/features/portfolio/providers/portfolio_providers.dart';
import 'package:ap_securities/features/trade/providers/trade_order_providers.dart';
import 'package:ap_securities/features/trade/providers/pend_order_providers.dart';
import 'package:ap_securities/features/trade/providers/trade_tab_providers.dart';
import 'package:ap_securities/providers/active_account_scope.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Drops cached tab data so the next read refetches for the current account.
void invalidateAccountScopedData(Ref ref) {
  ref
    ..invalidate(marketWatchlistProvider)
    ..invalidate(tradingSymbolCatalogByTypeProvider)
    ..invalidate(tradingSymbolFuzzySearchProvider)
    ..invalidate(tradeTabProvider)
    ..invalidate(pendOrderListProvider)
    ..invalidate(tradeOrderQuoteProvider)
    ..invalidate(historyPageProvider)
    ..invalidate(portfolioHoldingsProvider)
    ..invalidate(leaderboardRankListProvider)
    ..invalidate(announcementsListProvider);
}

/// Listens to [activeAccountScopeProvider]; must be watched from [App] only.
///
/// Kept separate from [accountSessionProvider] to avoid a provider import cycle.
final accountScopedDataRefreshProvider = Provider<void>((ref) {
  ref.listen(activeAccountScopeProvider, (previous, next) {
    if (previous == next) return;
    Future.microtask(() => invalidateAccountScopedData(ref));
  });
});
