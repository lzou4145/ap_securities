import 'dart:io';

import 'package:ap_securities/core/config/app_environment.dart';
import 'package:ap_securities/core/network/interceptors/app_api_headers_interceptor.dart';
import 'package:ap_securities/core/network/interceptors/auth_token_interceptor.dart';
import 'package:ap_securities/core/network/interceptors/logging_interceptor.dart';
import 'package:ap_securities/core/network/interceptors/retry_connection_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Builds a shared `Dio` instance wired for the current `AppEnvironment`.
Dio createAppDio({
  required AppEnvironment environment,
  ReadAccessToken readAccessToken = readAccessTokenAnonymous,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: environment.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: <String, dynamic>{
        Headers.acceptHeader: 'application/json',
      },
    ),
  );

  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 20);
      client.idleTimeout = const Duration(seconds: 15);
      return client;
    },
  );

  dio.interceptors.add(AuthTokenInterceptor(readAccessToken));
  dio.interceptors.add(AppApiHeadersInterceptor(readAccessToken));
  dio.interceptors.add(RetryConnectionInterceptor(dio));

  if (environment.enableNetworkTrafficLogging) {
    dio.interceptors.add(LoggingInterceptor());
  }

  return dio;
}
