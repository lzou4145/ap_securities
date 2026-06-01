import 'package:ap_securities/features/market/domain/market_price_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatMarketPrice uses decimalPlace', () {
    expect(
      formatMarketPrice(2113.7, decimalPlace: 2),
      '2113.70',
    );
    expect(
      formatMarketPrice(1.23456, decimalPlace: 5),
      '1.23456',
    );
  });

  test('minPriceMoveForDecimalPlace', () {
    expect(minPriceMoveForDecimalPlace(2), 0.01);
    expect(minPriceMoveForDecimalPlace(5), 0.00001);
    expect(minPriceMoveForDecimalPlace(0), 1);
  });

  test('roundMarketPrice', () {
    expect(roundMarketPrice(1.23456, 4), 1.2346);
    expect(roundMarketPrice(2113.456, 2), 2113.46);
  });
}
