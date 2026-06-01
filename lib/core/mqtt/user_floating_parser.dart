import 'package:ap_securities/core/mqtt/trade_mqtt_response.dart';

/// Account wallet push: `USER_FLOATING_BACK|account:amount:…` or
/// `USER_FLOATING_BACK|0:account:amount:equity:…`.
class UserFloatingUpdate {
  const UserFloatingUpdate({
    required this.accountId,
    required this.balance,
    this.equity,
    this.margin,
    this.freeMargin,
    this.marginLevelPercent,
  });

  final String accountId;
  final double balance;
  final double? equity;
  final double? margin;
  final double? freeMargin;
  final double? marginLevelPercent;
}

abstract final class UserFloatingParser {
  static const String prefix = 'USER_FLOATING_BACK|';

  static UserFloatingUpdate? tryParsePayload(String payload) {
    final trimmed = payload.trim();
    if (!trimmed.startsWith(prefix)) {
      return tryParseTradeResponse(payload);
    }
    return parseData(trimmed.substring(prefix.length));
  }

  static UserFloatingUpdate? tryParseTradeResponse(String payload) {
    final response = TradeMqttResponseParser.parse(payload);
    if (response == null ||
        response.operationType != TradeMqttOperationType.userFloatingBack) {
      return null;
    }
    return parseData(response.message);
  }

  /// `account:amount` or `0:account:amount:equity:bail:free:level`.
  static UserFloatingUpdate? parseData(String data) {
    final parts = data.split(':');
    if (parts.length < 2) return null;

    var index = 0;
    if (_isStatusCodePart(parts[0]) && parts.length >= 3) {
      index = 1;
    }

    if (parts.length - index < 2) return null;

    final accountId = parts[index];
    final balance = _dbl(parts[index + 1]);

    return UserFloatingUpdate(
      accountId: accountId,
      balance: balance,
      equity: parts.length > index + 2 ? _dbl(parts[index + 2]) : null,
      margin: parts.length > index + 3 ? _dbl(parts[index + 3]) : null,
      freeMargin: parts.length > index + 4 ? _dbl(parts[index + 4]) : null,
      marginLevelPercent:
          parts.length > index + 5 ? _dbl(parts[index + 5]) : null,
    );
  }

  static bool _isStatusCodePart(String part) {
    final code = int.tryParse(part.trim());
    return code != null && part.length <= 4;
  }

  static double _dbl(String raw) => double.tryParse(raw.trim()) ?? 0;
}
