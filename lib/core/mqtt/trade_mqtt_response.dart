/// Server push payload: `OPERATION|statusCode:message` (0 = success).
enum TradeMqttOperationType {
  userFloatingBack('USER_FLOATING_BACK'),
  tradeBack('TRADE_BACK'),
  followOrderBack('FOLLOW_ORDER_BACK'),
  orderBack('ORDER_BACK'),
  orderRemoveBack('ORDER_REMOVE_BACK'),
  closeOrderBack('CLOSE_ORDER_BACK'),
  positionSuccessBack('POSITION_SUCCESS_BACK'),
  positionFloatingBack('POSITION_FLOATING_BACK'),
  modifyProfitLossBack('MODIFY_PROFIT_LOSS_BACK'),
  orderModifyProfitLossBack('ORDER_MODIFY_PROFIT_LOSS_BACK'),
  unknown('');

  const TradeMqttOperationType(this.wireValue);

  final String wireValue;

  static TradeMqttOperationType fromWire(String value) {
    for (final type in TradeMqttOperationType.values) {
      if (type.wireValue == value) return type;
    }
    return TradeMqttOperationType.unknown;
  }
}

class TradeMqttResponse {
  const TradeMqttResponse({
    required this.operationType,
    required this.statusCode,
    required this.message,
    required this.raw,
  });

  final TradeMqttOperationType operationType;
  final int statusCode;
  final String message;
  final String raw;

  bool get isSuccess => statusCode == 0;

  /// Order id from the message tail when the server returns digits only.
  String? get orderId => TradeMqttResponseParser.extractOrderId(message);
}

abstract final class TradeMqttResponseParser {
  static final RegExp _orderIdPattern = RegExp(r'\d{8,}');

  /// Picks the longest digit run (e.g. `20260506142349080` from success payload).
  static String? extractOrderId(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return null;

    if (_orderIdPattern.hasMatch(trimmed) &&
        RegExp(r'^\d+$').hasMatch(trimmed)) {
      return trimmed;
    }

    String? best;
    for (final match in _orderIdPattern.allMatches(trimmed)) {
      final candidate = match.group(0);
      if (candidate == null) continue;
      if (best == null || candidate.length > best.length) {
        best = candidate;
      }
    }
    return best;
  }

  static TradeMqttResponse? parse(String payload) {
    final trimmed = payload.trim();
    if (trimmed.isEmpty) return null;

    final pipeIndex = trimmed.indexOf('|');
    if (pipeIndex <= 0 || pipeIndex >= trimmed.length - 1) return null;

    final operationWire = trimmed.substring(0, pipeIndex);
    final tail = trimmed.substring(pipeIndex + 1);
    final colonIndex = tail.indexOf(':');
    if (colonIndex <= 0) return null;

    final codeText = tail.substring(0, colonIndex);
    final statusCode = int.tryParse(codeText);
    if (statusCode == null) return null;

    var message = tail.substring(colonIndex + 1);
    while (message.startsWith(':')) {
      message = message.substring(1);
    }

    return TradeMqttResponse(
      operationType: TradeMqttOperationType.fromWire(operationWire),
      statusCode: statusCode,
      message: message,
      raw: trimmed,
    );
  }
}
