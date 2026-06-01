import 'package:ap_securities/core/api/app_api.dart';
import 'package:ap_securities/core/network/network.dart';
import 'package:ap_securities/providers/auth.dart';
import 'package:ap_securities/providers/environment.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(environmentProvider);
  final dio = createAppDio(
    environment: env,
    readAccessToken: () async {
      final auth = ref.read(authNotifierProvider);
      if (auth is AuthStateSignedIn) return auth.accessToken;
      return null;
    },
  );
  ref.onDispose(dio.close);
  return dio;
});

final appHttpClientProvider = Provider<AppHttpClient>((ref) {
  final dio = ref.watch(dioProvider);
  return AppHttpClient(dio: dio);
});

/// All APP-api endpoints grouped by OpenAPI category (登录注册 / 行情 / …).
final appApiProvider = Provider<AppApi>((ref) {
  return AppApi(ref.watch(appHttpClientProvider));
});
