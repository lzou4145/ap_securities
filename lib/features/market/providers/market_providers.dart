import 'package:ap_securities/features/market/data/market_repository.dart';
import 'package:ap_securities/features/market/domain/trading_symbol_candidate.dart';
import 'package:ap_securities/providers/active_account_scope.dart';
import 'package:ap_securities/providers/http_clients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return MarketRepository(ref.watch(appApiProvider));
});

final tradingSymbolCatalogByTypeProvider = FutureProvider.autoDispose
    .family<List<TradingSymbolCandidate>, String>((ref, type) async {
  ref.watch(activeAccountScopeProvider);
  final repo = ref.watch(marketRepositoryProvider);
  return repo.fetchCatalog(type: type, code: '');
});

final tradingSymbolFuzzySearchProvider = FutureProvider.autoDispose
    .family<List<TradingSymbolCandidate>, String>((ref, query) async {
  ref.watch(activeAccountScopeProvider);
  final repo = ref.watch(marketRepositoryProvider);
  return repo.fetchVarietyFuzzy(query);
});
