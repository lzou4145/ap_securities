import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

Future<void> main() async {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://appapi.nplus.top/',
      connectTimeout: const Duration(seconds: 15),
    ),
  );
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);
      return client;
    },
  );

  for (var i = 0; i < 5; i++) {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/api/getLoginCode',
        data: FormData.fromMap({'device_no': 'ssl-probe-$i'}),
      );
      stdout.writeln('ok $i: ${response.statusCode} ${response.data}');
    } on Object catch (e) {
      stdout.writeln('fail $i: $e');
    }
  }
}
