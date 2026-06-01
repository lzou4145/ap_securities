import 'package:ap_securities/core/api/models/api_models_market.dart';

/// Symbol available on the「添加交易品种」screen.
class TradingSymbolCandidate {
  const TradingSymbolCandidate({
    required this.varietyId,
    required this.symbol,
    required this.variety,
    this.name = '',
  });

  final int varietyId;
  final String symbol;
  final String name;
  final Variety variety;
}
