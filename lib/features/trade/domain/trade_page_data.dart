import 'package:ap_securities/features/trade/domain/open_position.dart';
import 'package:ap_securities/features/trade/domain/trade_account_summary.dart';

/// Trade tab payload — replace via [TradeRepository.fetchTradePage].
class TradePageData {
  const TradePageData({
    required this.totalProfitUsd,
    required this.summary,
    required this.positions,
    required this.followPositions,
  });

  final double totalProfitUsd;
  final TradeAccountSummary summary;
  final List<OpenPosition> positions;
  final List<OpenPosition> followPositions;
}
