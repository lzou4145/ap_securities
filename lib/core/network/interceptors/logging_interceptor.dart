import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Lightweight request/response logging for non-production builds.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({this.logBody = true});

  final bool logBody;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('--> ${options.method} ${options.uri}');
    if (logBody && options.data != null) {
      buffer.writeln(_stringify(options.data));
    }
    developer.log(buffer.toString(), name: 'HTTP');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final buffer = StringBuffer()
      ..writeln(
        '<-- ${response.statusCode} ${response.requestOptions.uri}',
      );
    if (logBody && response.data != null) {
      buffer.writeln(_stringify(response.data));
    }
    developer.log(buffer.toString(), name: 'HTTP');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      'xx ${err.response?.statusCode ?? ''} ${err.requestOptions.uri}\n$err',
      name: 'HTTP',
      error: err,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }

  String _stringify(Object? data) {
    try {
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      return data.toString();
    } on Object {
      return '<unprintable>';
    }
  }
}
