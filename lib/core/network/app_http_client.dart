import 'dart:async';

import 'package:ap_securities/core/api/api_business_codes.dart';
import 'package:ap_securities/core/api/api_envelope.dart';
import 'package:ap_securities/core/api/json/json_read.dart';
import 'package:ap_securities/core/auth/session_expired_host.dart';
import 'package:ap_securities/core/network/api_exception.dart';
import 'package:dio/dio.dart';

/// Typed, exception-mapped HTTP facade used by repositories / use-cases.
///
/// All APP-api responses use `{ code, msg, data }`. [code] `0` means success;
/// only [data] is returned to callers. Non-zero [code] throws [ApiException].
class AppHttpClient {
  AppHttpClient({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// GET — unwraps envelope and maps [data] with [fromJson].
  Future<T> getData<T>(
    String path, {
    required T Function(Object? json) fromJson,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final body = await _request(
      () => _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
    return fromJson(ApiEnvelope.parseData(body));
  }

  /// POST JSON — unwraps envelope; returns parsed [data].
  Future<T> postData<T>(
    String path, {
    required T Function(Object? json) fromJson,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final body = await _request(
      () => _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
    return fromJson(ApiEnvelope.parseData(body));
  }

  /// POST multipart/form-data — unwraps envelope; returns parsed [data].
  Future<T> postFormData<T>(
    String path, {
    required T Function(Object? json) fromJson,
    required FormData data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final body = await _request(
      () => _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
    return fromJson(ApiEnvelope.parseData(body));
  }

  /// GET — returns raw `data` field after envelope check.
  Future<Object?> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return getData<Object?>(
      path,
      fromJson: (json) => json,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST JSON — returns raw `data` field after envelope check.
  Future<Object?> postJson(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return postData<Object?>(
      path,
      fromJson: (json) => json,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST form — returns raw `data` field after envelope check.
  Future<Object?> postForm(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return postFormData<Object?>(
      path,
      fromJson: (json) => json,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Map<String, dynamic>> _request(
    Future<Response<Map<String, dynamic>>> Function() send,
  ) async {
    try {
      final response = await send();
      final data = response.data;
      if (data == null) {
        throw const ApiException(
          message: 'Empty response body',
          kind: ApiErrorKind.client,
        );
      }
      _notifySessionExpiredIfNeeded(data);
      return data;
    } on DioException catch (e, st) {
      final errBody = e.response?.data;
      if (errBody is Map<String, dynamic>) {
        _notifySessionExpiredIfNeeded(errBody);
      } else if (errBody is Map) {
        _notifySessionExpiredIfNeeded(Map<String, dynamic>.from(errBody));
      }
      throw ApiException.fromDio(e, st);
    } on ApiException {
      rethrow;
    }
  }

  void _notifySessionExpiredIfNeeded(Map<String, dynamic> body) {
    final code = JsonRead.asIntOrNull(body['code']);
    if (code == null || !ApiBusinessCodes.isTokenInvalid(code)) return;
    final handler = SessionExpiredHost.onSessionExpired;
    if (handler != null) unawaited(handler());
  }

  /// Escape hatch for advanced calls — still throws [ApiException].
  Future<Response<T>> rawRequest<T>(
    Future<Response<T>> Function(Dio dio) request,
  ) async {
    try {
      return await request(_dio);
    } on DioException catch (e, st) {
      throw ApiException.fromDio(e, st);
    }
  }
}
