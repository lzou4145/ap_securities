import 'package:ap_securities/core/api/api_envelope.dart';
import 'package:ap_securities/core/network/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiEnvelope', () {
    test('parseData returns data when code is 0', () {
      final data = ApiEnvelope.parseData({
        'code': 0,
        'msg': 'ok',
        'data': {'id': 1},
      });
      expect(data, {'id': 1});
    });

    test('parseData uses unauthorized kind for token-invalid codes', () {
      expect(
        () => ApiEnvelope.parseData({
          'code': -100,
          'msg': 'token失效',
          'data': null,
        }),
        throwsA(
          isA<ApiException>()
              .having((e) => e.businessCode, 'businessCode', -100)
              .having((e) => e.kind, 'kind', ApiErrorKind.unauthorized)
              .having((e) => e.isTokenInvalid, 'isTokenInvalid', true),
        ),
      );
    });

    test('parseData throws ApiException when code is not 0', () {
      expect(
        () => ApiEnvelope.parseData({
          'code': 1001,
          'msg': '登录失败',
          'data': null,
        }),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', '登录失败')
              .having((e) => e.businessCode, 'businessCode', 1001)
              .having((e) => e.kind, 'kind', ApiErrorKind.business),
        ),
      );
    });

    test('parse maps data with fromJson', () {
      final value = ApiEnvelope.parse<int>({
        'code': 0,
        'msg': 'ok',
        'data': 42,
      }, (data) => data! as int);
      expect(value, 42);
    });
  });
}
