import 'package:ap_securities/core/network/api_exception.dart';

/// MQTT success can arrive before the order row is persisted (~500ms).
abstract final class OrderInfoFetchRetry {
  static const initialDelay = Duration(milliseconds: 500);
  static const retryInterval = Duration(milliseconds: 350);
  static const maxAttempts = 8;

  /// True when the API likely means "not in DB yet", not a permanent failure.
  static bool isOrderNotReadyError(Object error) {
    if (error is! ApiException) return false;
    if (error.kind == ApiErrorKind.network ||
        error.kind == ApiErrorKind.timeout ||
        error.kind == ApiErrorKind.unauthorized) {
      return false;
    }
    if (error.statusCode == 404) return true;

    final msg = error.message.toLowerCase();
    return msg.contains('不存在') ||
        msg.contains('未找到') ||
        msg.contains('not found') ||
        msg.contains('not exist') ||
        msg.contains('does not exist');
  }
}
