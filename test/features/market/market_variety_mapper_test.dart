import 'package:ap_securities/core/api/models/api_models_market.dart';
import 'package:ap_securities/features/market/data/market_variety_mapper.dart';
import 'package:ap_securities/features/market/domain/market_quote.dart';
import 'package:ap_securities/features/market/domain/trading_symbol_detail.dart';
import 'package:flutter_test/flutter_test.dart';

const _variety12 = Variety(
  id: 12,
  code: 'XAUUSD',
  name: 'Gold',
  pointDiff: 10,
  pointDiffMax: 0,
  feeInventoryShort: '-1',
  feeInventoryLong: '-1',
  unit: 'USD',
  multiplier: 100,
  undulateMin: '0.01',
  onlineStatus: 1,
  bailHedge: '50',
  bailPercent: '1',
  decimalPlace: 2,
  stopLossLevel: 5,
  type: 1,
);

const _variety34 = Variety(
  id: 34,
  code: 'EURUSD',
  name: 'Euro',
  pointDiff: 8,
  pointDiffMax: 0,
  feeInventoryShort: '-1',
  feeInventoryLong: '-1',
  unit: 'USD',
  multiplier: 100000,
  undulateMin: '0.00001',
  onlineStatus: 1,
  bailHedge: '50',
  bailPercent: '1',
  decimalPlace: 5,
  stopLossLevel: 0,
  type: 1,
);

void main() {
  test('buildSortJson uses variety id keys with 1-based order values', () {
    const quotes = [
      MarketQuote(
        id: '12',
        symbol: 'XAUUSD',
        variety: _variety12,
        updatedAt: '--',
        decimalPlace: 2,
        spread: 10,
        bid: 0,
        ask: 0,
        bidLow: 0,
        askHigh: 0,
        trend: QuoteTrend.up,
      ),
      MarketQuote(
        id: '34',
        symbol: 'EURUSD',
        variety: _variety34,
        updatedAt: '--',
        decimalPlace: 2,
        spread: 10,
        bid: 0,
        ask: 0,
        bidLow: 0,
        askHigh: 0,
        trend: QuoteTrend.up,
      ),
    ];

    expect(
      MarketVarietyMapper.buildSortJson(quotes),
      '{"12":1,"34":2}',
    );
  });

  test('detailFromVariety maps variety fields without API', () {
    final detail = MarketVarietyMapper.detailFromVariety(_variety12);

    expect(detail.symbol, 'XAUUSD');
    expect(
      detail.rows.map((r) => r.field).toList(),
      contains(SymbolDetailField.spread),
    );
    expect(
      detail.rows.firstWhere((r) => r.field == SymbolDetailField.digits).value,
      '2.00',
    );
    expect(
      detail.rows.firstWhere((r) => r.field == SymbolDetailField.spread).value,
      '10.00',
    );
    expect(
      detail.rows
          .firstWhere((r) => r.field == SymbolDetailField.profitCalculation)
          .value,
      'forex',
    );
    expect(
      detail.rows.firstWhere((r) => r.field == SymbolDetailField.gtcPending).value,
      'yes',
    );
    expect(
      detail.rows.firstWhere((r) => r.field == SymbolDetailField.swapType).value,
      'USD',
    );
  });

  test('spread shows floating when point diff range differs', () {
    const variety = Variety(
      id: 1,
      code: 'TEST',
      name: 'Test',
      pointDiff: 10,
      pointDiffMax: 20,
      feeInventoryShort: '0',
      feeInventoryLong: '0',
      unit: 'USD',
      multiplier: 1,
      undulateMin: '0',
      onlineStatus: 1,
      bailHedge: '0',
      bailPercent: '0',
      decimalPlace: 2,
      stopLossLevel: 0,
      type: 1,
    );
    final spread = MarketVarietyMapper.detailFromVariety(variety)
        .rows
        .firstWhere((r) => r.field == SymbolDetailField.spread);
    expect(spread.value, 'floating');
  });
}
