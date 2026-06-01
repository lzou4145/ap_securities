import 'package:ap_securities/core/config/app_environment.dart';
import 'package:ap_securities/core/network/network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('createAppDio', () {
    test('development registers auth + logging interceptors', () {
      final dio = createAppDio(environment: AppEnvironment.development);
      expect(dio.interceptors.any((i) => i is LoggingInterceptor), isTrue);
      expect(dio.options.baseUrl, 'https://appapi.nplus.top/');
    });

    test('production skips traffic logging interceptor', () {
      final dio = createAppDio(environment: AppEnvironment.production);
      expect(dio.interceptors.any((i) => i is LoggingInterceptor), isFalse);
    });
  });
}
