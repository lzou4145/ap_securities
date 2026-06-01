import 'package:dio/dio.dart';

typedef ReadAccessToken = Future<String?> Function();

Future<String?> readAccessTokenAnonymous() async => null;

/// Injects `Authorization: Bearer <token>` when the reader returns a value.
class AuthTokenInterceptor extends QueuedInterceptor {
  AuthTokenInterceptor(this._readAccessToken);

  final ReadAccessToken _readAccessToken;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
