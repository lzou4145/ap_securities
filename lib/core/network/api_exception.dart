import 'dart:io';

import 'package:ap_securities/core/api/api_business_codes.dart';
import 'package:ap_securities/core/api/json/json_read.dart';
import 'package:dio/dio.dart';

/// Normalized failure for API calls. Map UI copy from `kind` and `message`.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.kind = ApiErrorKind.unknown,
    this.statusCode,
    this.businessCode,
    this.cause,
    this.stackTrace,
  });

  factory ApiException.fromDio(DioException e, StackTrace stackTrace) {
    final response = e.response;
    final statusCode = response?.statusCode;
    final body = response?.data;
    var message = e.message ?? 'Network error';
    int? businessCode;
    var kind = _kindForDio(e.type, statusCode);

    final handshakeMessage = _handshakeUserMessage(e);
    if (handshakeMessage != null) {
      message = handshakeMessage;
      kind = ApiErrorKind.network;
    }

    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      final apiMsg = JsonRead.asStringOrNull(map['msg']);
      if (apiMsg != null && apiMsg.isNotEmpty) {
        message = apiMsg;
      } else {
        final serverMsg =
            map['message'] as String? ?? map['error'] as String?;
        if (serverMsg != null && serverMsg.isNotEmpty) {
          message = serverMsg;
        }
      }
      businessCode = JsonRead.asIntOrNull(map['code']);
      if (businessCode != null && businessCode != 0) {
        return ApiException(
          message: message,
          kind: ApiBusinessCodes.isTokenInvalid(businessCode)
              ? ApiErrorKind.unauthorized
              : ApiErrorKind.business,
          statusCode: statusCode,
          businessCode: businessCode,
          cause: e,
          stackTrace: stackTrace,
        );
      }
    }

    return ApiException(
      message: message,
      kind: kind,
      statusCode: statusCode,
      businessCode: businessCode,
      cause: e,
      stackTrace: stackTrace,
    );
  }

  static String? _handshakeUserMessage(DioException e) {
    final inner = e.error;
    if (inner is HandshakeException ||
        inner is TlsException ||
        (e.message?.contains('HandshakeException') ?? false) ||
        (e.message?.contains('Connection terminated during handshake') ??
            false)) {
      return '网络连接失败，请检查网络后重试';
    }
    return null;
  }

  static ApiErrorKind _kindForDio(DioExceptionType type, int? status) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiErrorKind.timeout;
      case DioExceptionType.connectionError:
        return ApiErrorKind.network;
      case DioExceptionType.badResponse:
        if (status == 401) return ApiErrorKind.unauthorized;
        if (status != null && status >= 500) return ApiErrorKind.server;
        return ApiErrorKind.client;
      case DioExceptionType.cancel:
        return ApiErrorKind.cancelled;
      case DioExceptionType.badCertificate:
        return ApiErrorKind.network;
      case DioExceptionType.unknown:
        return ApiErrorKind.unknown;
    }
  }

  final String message;
  final ApiErrorKind kind;
  final int? statusCode;

  /// Business `code` from `{ code, msg, data }` when not zero.
  final int? businessCode;
  final Object? cause;
  final StackTrace? stackTrace;

  bool get isTokenInvalid =>
      businessCode != null && ApiBusinessCodes.isTokenInvalid(businessCode!);

  @override
  String toString() {
    if (businessCode != null) {
      return 'ApiException($kind, businessCode=$businessCode): $message';
    }
    return 'ApiException($kind, $statusCode): $message';
  }
}

enum ApiErrorKind {
  network,
  timeout,
  unauthorized,
  business,
  client,
  server,
  cancelled,
  unknown,
}
