import 'package:ap_securities/core/mqtt/user_floating_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses USER_FLOATING_BACK with status code prefix', () {
    const payload =
        'USER_FLOATING_BACK|0:1000084:194069.70:119542.37:11752.14:107790.23:1017.2';

    final update = UserFloatingParser.tryParsePayload(payload);
    expect(update, isNotNull);
    expect(update!.accountId, '1000084');
    expect(update.balance, 194069.70);
    expect(update.equity, 119542.37);
  });
}
