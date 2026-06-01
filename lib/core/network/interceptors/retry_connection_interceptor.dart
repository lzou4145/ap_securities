import 'dart:io';

import 'package:dio/dio.dart';

/// Retries transient TLS / connection failures (e.g. Cloudflare handshake drops).
class RetryConnectionInterceptor extends Interceptor {
  RetryConnectionInterceptor(
    this._dio, {
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 400),
  });

  final Dio _dio;
  final int maxAttempts;
  final Duration baseDelay;

  static const _retryCountKey = 'retry_connection_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    final attempt = (err.requestOptions.extra[_retryCountKey] as int?) ?? 0;
    if (attempt >= maxAttempts - 1) {
      handler.next(err);
      return;
    }

    await Future<void>.delayed(baseDelay * (attempt + 1));

    try {
      final options = err.requestOptions;
      options.extra[_retryCountKey] = attempt + 1;
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryErr) {
      handler.next(retryErr);
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      final inner = err.error;
      if (inner is HandshakeException ||
          inner is SocketException ||
          inner is TlsException) {
        return true;
      }
      final message = err.message ?? '';
      if (message.contains('HandshakeException') ||
          message.contains('Connection terminated during handshake')) {
        return true;
      }
    }
    return false;
  }
}
