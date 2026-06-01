import 'package:ap_securities/core/network/api_exception.dart';
import 'package:ap_securities/features/trade/data/order_info_fetch_retry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isOrderNotReadyError matches order missing messages', () {
    expect(
      OrderInfoFetchRetry.isOrderNotReadyError(
        const ApiException(message: '订单不存在'),
      ),
      isTrue,
    );
    expect(
      OrderInfoFetchRetry.isOrderNotReadyError(
        const ApiException(message: 'Order does not exist', statusCode: 404),
      ),
      isTrue,
    );
  });

  test('isOrderNotReadyError ignores network failures', () {
    expect(
      OrderInfoFetchRetry.isOrderNotReadyError(
        const ApiException(
          message: 'timeout',
          kind: ApiErrorKind.timeout,
        ),
      ),
      isFalse,
    );
  });
}
