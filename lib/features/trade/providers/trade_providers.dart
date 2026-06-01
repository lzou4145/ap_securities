import 'package:ap_securities/features/trade/data/trade_repository.dart';
import 'package:ap_securities/providers/http_clients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tradeRepositoryProvider = Provider<TradeRepository>((ref) {
  ref.watch(appHttpClientProvider);
  return TradeRepository();
});
