import 'package:ap_securities/core/api/models/api_models_follow.dart';
import 'package:ap_securities/core/network/api_exception.dart';
import 'package:ap_securities/features/personalized_trading/data/personalized_trading_repository.dart';
import 'package:ap_securities/features/personalized_trading/domain/leaderboard_rank_page.dart';
import 'package:ap_securities/providers/active_account_scope.dart';
import 'package:ap_securities/providers/http_clients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final personalizedTradingRepositoryProvider =
    Provider<PersonalizedTradingRepository>((ref) {
  return PersonalizedTradingRepository(ref.watch(appApiProvider));
});

final leaderboardSearchQueryProvider = StateProvider<String>((ref) => '');

final leaderboardTradingTimeProvider =
    StateProvider<String>((ref) => '7d');

final leaderboardRankingMethodProvider =
    StateProvider<String>((ref) => 'top20');

final leaderboardRankListProvider =
    FutureProvider<LeaderboardRankPageData>((ref) async {
  ref.watch(activeAccountScopeProvider);
  final repo = ref.watch(personalizedTradingRepositoryProvider);
  final search = ref.watch(leaderboardSearchQueryProvider);
  final tradingTime = ref.watch(leaderboardTradingTimeProvider);
  final ranking = ref.watch(leaderboardRankingMethodProvider);

  try {
    return await repo.fetchRankList(
      tradingTimeKey: tradingTime,
      rankingMethodKey: ranking,
      accountId: search,
    );
  } on ApiException catch (e) {
    if (search.trim().isNotEmpty && e.kind == ApiErrorKind.business) {
      return LeaderboardRankPageData(
        updatedAt: DateTime.now(),
        ranks: const [],
      );
    }
    rethrow;
  }
});

final singleProviderConfigProvider = FutureProvider<SingleConfig>((ref) async {
  ref.watch(activeAccountScopeProvider);
  return ref.read(personalizedTradingRepositoryProvider).getSingleConfig();
});

final followDetailsFollowingProvider =
    FutureProvider.autoDispose<List<SingleTraderItem>>((ref) async {
  ref.watch(activeAccountScopeProvider);
  return ref.read(personalizedTradingRepositoryProvider).getSingleList();
});
