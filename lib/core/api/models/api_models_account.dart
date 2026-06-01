import 'package:ap_securities/core/api/json/json_read.dart';

/// `GET /api/account/getWalletsTrade` — live account wallet snapshot.
class AccountWalletsTrade {
  const AccountWalletsTrade({
    required this.amount,
    required this.closePosition,
  });

  factory AccountWalletsTrade.fromJson(Object? json) {
    final map = JsonRead.map(json);
    return AccountWalletsTrade(
      amount: JsonRead.asString(map['amount']),
      closePosition: JsonRead.asString(map['close_position']),
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'close_position': closePosition,
      };

  /// Account balance (结余).
  final String amount;

  /// Closed P/L or related closed-position metric from API.
  final String closePosition;
}
