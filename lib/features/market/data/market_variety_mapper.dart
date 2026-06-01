import 'dart:convert';

import 'package:ap_securities/core/api/models/api_models_market.dart';
import 'package:ap_securities/features/market/domain/market_quote.dart';
import 'package:ap_securities/features/market/domain/trading_symbol_candidate.dart';
import 'package:ap_securities/features/market/domain/trading_symbol_detail.dart';

/// Maps APP-api variety payloads to market UI models.
abstract final class MarketVarietyMapper {
  static List<MarketQuote> watchlistFromGroupMap(VarietyGroupMap groups) {
    final items = [...groups.all]..sort((a, b) => a.sort.compareTo(b.sort));
    return items.map(quoteFromAccountItem).toList();
  }

  static MarketQuote quoteFromAccountItem(AccountVarietyItem item) {
    final variety = item.variety;
    final symbol = variety.code.isNotEmpty ? variety.code : variety.name;
    return MarketQuote(
      id: item.varietyId.toString(),
      symbol: symbol,
      variety: variety,
      updatedAt: '--:--:--',
      decimalPlace: variety.decimalPlace,
      spread: variety.pointDiff,
      bid: 0,
      ask: 0,
      bidLow: 0,
      askHigh: 0,
      trend: QuoteTrend.up,
    );
  }

  static TradingSymbolCandidate candidateFromVariety(Variety variety) {
    final symbol = variety.code.isNotEmpty ? variety.code : variety.name;
    return TradingSymbolCandidate(
      varietyId: variety.id,
      symbol: symbol,
      name: variety.name,
      variety: variety,
    );
  }

  static TradingSymbolDetail detailFromVariety(Variety variety) {
    final symbol =
        variety.code.isNotEmpty ? variety.code : variety.name;
    return TradingSymbolDetail(
      symbol: symbol,
      rows: [
        TradingSymbolDetailRow(
          field: SymbolDetailField.spread,
          value: _spreadDisplayValue(variety),
        ),
        TradingSymbolDetailRow(
          field: SymbolDetailField.digits,
          value: decimal2(variety.decimalPlace),
        ),
        TradingSymbolDetailRow(
          field: SymbolDetailField.stopLevel,
          value: decimal2(variety.stopLossLevel),
        ),
        TradingSymbolDetailRow(
          field: SymbolDetailField.contractSize,
          value: decimal2(variety.multiplier),
        ),
        const TradingSymbolDetailRow(
          field: SymbolDetailField.profitCalculation,
          value: 'forex',
        ),
        const TradingSymbolDetailRow(
          field: SymbolDetailField.marginCalculation,
          value: 'forex',
        ),
        TradingSymbolDetailRow(
          field: SymbolDetailField.marginHedging,
          value: decimal2String(variety.bailHedge),
        ),
        TradingSymbolDetailRow(
          field: SymbolDetailField.marginPercentage,
          value: decimal2String(variety.bailPercent),
        ),
        const TradingSymbolDetailRow(
          field: SymbolDetailField.gtcPending,
          value: 'yes',
        ),
        TradingSymbolDetailRow(
          field: SymbolDetailField.swapType,
          value: variety.unit,
        ),
        TradingSymbolDetailRow(
          field: SymbolDetailField.swapLong,
          value: decimal2String(variety.feeInventoryLong),
        ),
        TradingSymbolDetailRow(
          field: SymbolDetailField.swapShort,
          value: decimal2String(variety.feeInventoryShort),
        ),
      ],
    );
  }

  /// Same [point_diff] / [point_diff_max] → single value; else floating spread.
  static String _spreadDisplayValue(Variety variety) {
    final same = variety.pointDiffMax <= 0 ||
        variety.pointDiff == variety.pointDiffMax;
    if (!same) return 'floating';
    return decimal2(variety.pointDiff);
  }

  static String decimal2(num value) => value.toStringAsFixed(2);

  static String decimal2String(String raw) {
    final parsed = double.tryParse(raw.trim());
    if (parsed == null) return raw;
    return parsed.toStringAsFixed(2);
  }

  /// API expects `{"<variety_id>": <order>, ...}` e.g. `{"12":1,"34":2}`.
  static String buildSortJson(List<MarketQuote> quotes) {
    final sortMap = <String, int>{};
    for (var i = 0; i < quotes.length; i++) {
      sortMap[quotes[i].id] = i + 1;
    }
    return jsonEncode(sortMap);
  }
}
