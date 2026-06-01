import 'package:ap_securities/features/market/domain/market_spread.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ETHUSDT example from MQTT doc', () {
    expect(
      marketSpreadFromPrices(bid: 2113.69, ask: 2113.7, decimalPlace: 2),
      1,
    );
  });

  test('same bid and ask yields zero spread', () {
    expect(
      marketSpreadFromPrices(bid: 1.2345, ask: 1.2345, decimalPlace: 4),
      0,
    );
  });

  test('decimal_place 4', () {
    expect(
      marketSpreadFromPrices(bid: 1.1234, ask: 1.1238, decimalPlace: 4),
      4,
    );
  });
}
