import 'package:ap_securities/features/market/presentation/widgets/quote_price_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseQuotePriceText', () {
    test('≤2 decimals: entire fractional part is large', () {
      final parts = parseQuotePriceText('229.58', decimalPlace: 2);
      expect(parts.prefix, '229.');
      expect(parts.pips, '58');
      expect(parts.pipette, '');
    });

    test('≤2 decimals with one fractional digit', () {
      final parts = parseQuotePriceText('2113.7', decimalPlace: 2);
      expect(parts.prefix, '2113.');
      expect(parts.pips, '7');
      expect(parts.pipette, '');
    });

    test('≥3 decimals: last two large, last one superscript', () {
      final parts = parseQuotePriceText('229.58000', decimalPlace: 5);
      expect(parts.prefix, '229.58');
      expect(parts.pips, '00');
      expect(parts.pipette, '0');
    });

    test('three fractional digits', () {
      final parts = parseQuotePriceText('229.580', decimalPlace: 3);
      expect(parts.prefix, '229.');
      expect(parts.pips, '58');
      expect(parts.pipette, '0');
    });

    test('four fractional digits', () {
      final parts = parseQuotePriceText('1.2345', decimalPlace: 4);
      expect(parts.prefix, '1.2');
      expect(parts.pips, '34');
      expect(parts.pipette, '5');
    });
  });

  group('formatQuoteDisplayPrice', () {
    test('uses decimalPlace from variety', () {
      expect(formatQuoteDisplayPrice(1.23456789, 2), '1.23');
      expect(formatQuoteDisplayPrice(77486.2, 2), '77486.20');
      expect(formatQuoteDisplayPrice(1.23456, 5), '1.23456');
    });

    test('zero or negative shows placeholder', () {
      expect(formatQuoteDisplayPrice(0, 2), '--');
    });
  });
}
