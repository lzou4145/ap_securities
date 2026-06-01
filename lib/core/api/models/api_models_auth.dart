import 'package:ap_securities/core/api/json/json_read.dart';
import 'package:ap_securities/core/api/models/api_models_account.dart';
import 'package:ap_securities/core/api/models/api_models_common.dart';

class WalletsTrade {
  const WalletsTrade({
    required this.accountId,
    required this.amount,
    required this.bail,
    required this.lever,
    this.closePosition = '',
  });

  factory WalletsTrade.fromJson(Map<String, dynamic> json) {
    return WalletsTrade(
      accountId: JsonRead.asInt(json['account_id']),
      amount: JsonRead.asString(json['amount']),
      bail: JsonRead.asString(json['bail']),
      lever: JsonRead.asInt(json['lever']),
      closePosition: JsonRead.asStringOrNull(json['close_position']) ?? '',
    );
  }

  /// Applies [AccountWalletsTrade] from `getWalletsTrade`, keeping login fields.
  WalletsTrade withAccountSnapshot(AccountWalletsTrade snapshot) {
    return WalletsTrade(
      accountId: accountId,
      amount: snapshot.amount,
      bail: bail,
      lever: lever,
      closePosition: snapshot.closePosition,
    );
  }

  Map<String, dynamic> toJson() => {
        'account_id': accountId,
        'amount': amount,
        'bail': bail,
        'lever': lever,
        if (closePosition.isNotEmpty) 'close_position': closePosition,
      };

  final int accountId;
  final String amount;
  final String bail;
  final int lever;

  /// From `GET /api/account/getWalletsTrade` (`close_position`).
  final String closePosition;
}

/// Login / switch-account session payload.
class AuthSession {
  const AuthSession({
    required this.accountId,
    required this.userId,
    required this.main,
    required this.accountName,
    required this.token,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.redisKey,
    this.walletsTrade,
  });

  factory AuthSession.fromJson(Object? json) {
    final map = JsonRead.map(json);
    return AuthSession(
      accountId: JsonRead.asInt(map['account_id']),
      userId: JsonRead.asInt(map['user_id']),
      main: JsonRead.asInt(map['main']),
      accountName: JsonRead.asString(map['account_name']),
      token: JsonRead.asString(map['token']),
      createdAt: JsonRead.asStringOrNull(map['created_at']),
      updatedAt: JsonRead.asStringOrNull(map['updated_at']),
      deletedAt: JsonRead.asStringOrNull(map['deleted_at']),
      redisKey: JsonRead.asStringOrNull(map['redis_key']),
      walletsTrade: map['wallets_trade'] is Map
          ? WalletsTrade.fromJson(JsonRead.map(map['wallets_trade']))
          : null,
    );
  }

  final int accountId;
  final int userId;
  final int main;
  final String accountName;
  final String token;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? redisKey;
  final WalletsTrade? walletsTrade;
}

class RegCredential {
  const RegCredential({required this.account, required this.pass});

  factory RegCredential.fromJson(Map<String, dynamic> json) {
    return RegCredential(
      account: JsonRead.asString(json['account']),
      pass: JsonRead.asString(json['pass']),
    );
  }

  final String account;
  final String pass;
}

class RegResult {
  const RegResult({this.adminInfo, this.appInfo});

  factory RegResult.fromJson(Object? json) {
    final map = JsonRead.map(json);
    return RegResult(
      adminInfo: map['admin_info'] is Map
          ? RegCredential.fromJson(JsonRead.map(map['admin_info']))
          : null,
      appInfo: map['app_info'] is Map
          ? RegCredential.fromJson(JsonRead.map(map['app_info']))
          : null,
    );
  }

  final RegCredential? adminInfo;
  final RegCredential? appInfo;
}

class LoginCodeData {
  const LoginCodeData({
    required this.code,
    this.image,
    this.img,
  });

  factory LoginCodeData.fromJson(Object? json) {
    final map = JsonRead.map(json);
    return LoginCodeData(
      code: JsonRead.asString(map['code']),
      image: JsonRead.asStringOrNull(map['image']),
      img: JsonRead.asStringOrNull(map['img']),
    );
  }

  /// Captcha image (base64) or legacy encoded payload from `getLoginCode`.
  final String code;

  /// Optional explicit image field when API splits image from session key.
  final String? image;
  final String? img;
}

class DeviceAccountBinding {
  const DeviceAccountBinding({
    required this.deviceNo,
    required this.accountId,
    required this.account,
  });

  factory DeviceAccountBinding.fromJson(Map<String, dynamic> json) {
    return DeviceAccountBinding(
      deviceNo: JsonRead.asString(json['device_no']),
      accountId: JsonRead.asInt(json['account_id']),
      account: JsonRead.asString(json['account']),
    );
  }

  final String deviceNo;
  final int accountId;
  final String account;
}

List<DeviceAccountBinding> parseDeviceAccountBindings(Object? json) =>
    parseListOrEmpty(json, DeviceAccountBinding.fromJson);
