import 'package:ap_securities/core/network/interceptors/auth_token_interceptor.dart';
import 'package:dio/dio.dart';

/// Injects APP-api headers from the OpenAPI spec (`token` / `platform`).
///
/// [AuthTokenInterceptor] still adds `Authorization: Bearer` when a token exists.
class AppApiHeadersInterceptor extends QueuedInterceptor {
  AppApiHeadersInterceptor(
    this._readAccessToken, {
    this.platform = 'app',
  });

  final ReadAccessToken _readAccessToken;
  final String platform;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.putIfAbsent('platform', () => platform);
    options.headers.putIfAbsent('Platform', () => platform);

    final token = await _readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers.putIfAbsent('token', () => token);
      options.headers.putIfAbsent('Token', () => token);
    }

    handler.next(options);
  }
}
