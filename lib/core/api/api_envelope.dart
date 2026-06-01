import 'package:ap_securities/core/api/api_business_codes.dart';
import 'package:ap_securities/core/api/json/json_read.dart';
import 'package:ap_securities/core/network/api_exception.dart';

/// Standard APP-api response: `{ "code": 0, "msg": "...", "data": ... }`.
abstract final class ApiEnvelope {
  static const int successCode = 0;

  /// Returns the `data` field when [code] is [successCode]; otherwise throws.
  static Object? parseData(Map<String, dynamic> body) {
    final code = JsonRead.asInt(body['code'], defaultValue: -1);
    final msg = JsonRead.asString(body['msg'], defaultValue: '请求失败');
    if (code != successCode) {
      throw ApiException(
        message: msg,
        kind: ApiBusinessCodes.isTokenInvalid(code)
            ? ApiErrorKind.unauthorized
            : ApiErrorKind.business,
        businessCode: code,
      );
    }
    return body['data'];
  }

  static T parse<T>(
    Map<String, dynamic> body,
    T Function(Object? data) fromData,
  ) {
    return fromData(parseData(body));
  }
}
