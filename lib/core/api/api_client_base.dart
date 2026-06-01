import 'package:ap_securities/core/network/app_http_client.dart';
import 'package:dio/dio.dart';

/// Shared helpers for generated APP-api clients.
abstract class ApiClientBase {
  ApiClientBase(this._http);

  final AppHttpClient _http;

  AppHttpClient get http => _http;

  static Map<String, dynamic> query(Map<String, dynamic> values) {
    return Map<String, dynamic>.from(values)..removeWhere((_, v) => v == null);
  }

  static FormData form(Map<String, dynamic> fields) {
    return FormData.fromMap(
      Map<String, dynamic>.from(fields)..removeWhere((_, v) => v == null),
    );
  }
}
