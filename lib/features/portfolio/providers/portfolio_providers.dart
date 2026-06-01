import 'package:ap_securities/features/portfolio/data/portfolio_repository.dart';
import 'package:ap_securities/features/portfolio/domain/holding_row.dart';
import 'package:ap_securities/providers/active_account_scope.dart';
import 'package:ap_securities/providers/http_clients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  ref.watch(appHttpClientProvider);
  return PortfolioRepository();
});

final portfolioHoldingsProvider =
    FutureProvider.autoDispose<List<HoldingRow>>((ref) async {
  ref.watch(activeAccountScopeProvider);
  final repo = ref.watch(portfolioRepositoryProvider);
  return repo.fetchHoldings();
});
