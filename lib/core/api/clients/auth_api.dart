import 'package:ap_securities/core/api/api_client_base.dart';
import 'package:ap_securities/core/api/app_api_paths.dart';
import 'package:ap_securities/core/api/models/api_models_auth.dart';
import 'package:ap_securities/core/api/models/api_models_common.dart';

/// APP-api / 登录注册
class AuthApi extends ApiClientBase {
  AuthApi(super.http);

  /// 切换账号
  /// `POST /api/changeAccountByDeviceNo`
  Future<AuthSession> changeAccountByDeviceNo(
      String? deviceNo, String? accountId) async {
    return http.postFormData(
      AppApiPaths.changeAccountByDeviceNo,
      fromJson: AuthSession.fromJson,
      data: ApiClientBase.form(
          <String, dynamic>{'device_no': deviceNo, 'account_id': accountId}),
    );
  }

  /// 注册
  /// `POST /api/reg`
  Future<RegResult> reg(String? email, String? mobile, String? regType,
      String? inviteCode, String? code, String? password) async {
    return http.postFormData(
      AppApiPaths.reg,
      fromJson: RegResult.fromJson,
      data: ApiClientBase.form(<String, dynamic>{
        'email': email,
        'mobile': mobile,
        'reg_type': regType,
        'invite_code': inviteCode,
        'code': code,
        'password': password
      }),
    );
  }

  /// 发送验证码
  /// `POST /api/sendCode`
  Future<void> sendCode(
      String? regType, String? type, String? email, String? mobile) async {
    return http.postFormData(
      AppApiPaths.sendCode,
      fromJson: parseVoid,
      data: ApiClientBase.form(<String, dynamic>{
        'reg_type': regType,
        'type': type,
        'email': email,
        'mobile': mobile
      }),
    );
  }

  /// 获取登录验证码
  /// `POST /api/getLoginCode`
  Future<LoginCodeData> getLoginCode(String? deviceNo) async {
    return http.postFormData(
      AppApiPaths.getLoginCode,
      fromJson: LoginCodeData.fromJson,
      data: ApiClientBase.form(<String, dynamic>{'device_no': deviceNo}),
    );
  }

  /// 重置 MQTT Key
  /// `POST /api/initMqttKey`
  Future<void> initMqttKey(String? deviceNo) async {
    return http.postFormData(
      AppApiPaths.initMqttKey,
      fromJson: parseVoid,
      data: ApiClientBase.form(<String, dynamic>{'device_no': deviceNo}),
    );
  }

  /// 登出
  /// `POST /api/logout`
  Future<void> logout(String? deviceNo) async {
    return http.postFormData(
      AppApiPaths.logout,
      fromJson: parseVoid,
      data: ApiClientBase.form(<String, dynamic>{'device_no': deviceNo}),
    );
  }

  /// 登录
  /// `POST /api/login`
  Future<AuthSession> login(String? accountId, String? password,
      String? deviceNo, String? loginCode) async {
    return http.postFormData(
      AppApiPaths.login,
      fromJson: AuthSession.fromJson,
      data: ApiClientBase.form(<String, dynamic>{
        'account_id': accountId,
        'password': password,
        'device_no': deviceNo,
        'login_code': loginCode
      }),
    );
  }

  /// 添加账号
  /// `POST /api/addAccountByDeviceNo`
  Future<void> addAccountByDeviceNo(
      String? deviceNo, String? accountId, String? password) async {
    return http.postFormData(
      AppApiPaths.addAccountByDeviceNo,
      fromJson: parseVoid,
      data: ApiClientBase.form(<String, dynamic>{
        'device_no': deviceNo,
        'account_id': accountId,
        'password': password
      }),
    );
  }

  /// 获取账号
  /// `GET /api/getAccountByDeviceNo`
  Future<List<DeviceAccountBinding>> getAccountByDeviceNo(
      String? deviceNo) async {
    return http.getData(
      AppApiPaths.getAccountByDeviceNo,
      fromJson: parseDeviceAccountBindings,
      queryParameters:
          ApiClientBase.query(<String, dynamic>{'device_no': deviceNo}),
    );
  }
}
