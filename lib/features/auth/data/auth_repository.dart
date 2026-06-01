import 'package:ap_securities/core/api/app_api.dart';
import 'package:ap_securities/core/api/models/api_models_auth.dart' as api;
import 'package:ap_securities/features/account/data/account_repository.dart';
import 'package:ap_securities/features/auth/data/login_captcha_loader.dart';
import 'package:ap_securities/features/auth/domain/login_captcha_challenge.dart';

/// Login / logout against APP-api (`/api/getLoginCode`, `/api/login`).
class AuthRepository {
  AuthRepository({
    required AppApi api,
    required AccountRepository accountRepository,
  })  : _api = api,
        _accountRepository = accountRepository;

  final AppApi _api;
  final AccountRepository _accountRepository;

  /// Fetches captcha for login (`POST /api/getLoginCode`, Base64 `code` via
  /// [decodeLoginCode] when not an image).
  Future<LoginCaptchaChallenge> fetchLoginCaptcha() async {
    final deviceNo = await _accountRepository.getOrCreateDeviceNo();
    final payload = await _api.auth.getLoginCode(deviceNo);
    return loadLoginCaptchaChallenge(payload);
  }

  Future<api.AuthSession> loginWithPassword({
    required String accountId,
    required String password,
    required String loginCode,
  }) async {
    final deviceNo = await _accountRepository.getOrCreateDeviceNo();
    return _api.auth.login(
      accountId,
      password,
      deviceNo,
      loginCode.trim(),
    );
  }

  /// Switches the active account bound to this device.
  Future<api.AuthSession> switchAccountOnDevice({
    required String accountId,
  }) async {
    final deviceNo = await _accountRepository.getOrCreateDeviceNo();
    return _api.auth.changeAccountByDeviceNo(deviceNo, accountId);
  }

  /// Binds account to this device, then switches to it and returns session.
  Future<api.AuthSession> addAccountOnDevice({
    required String accountId,
    required String password,
  }) async {
    final deviceNo = await _accountRepository.getOrCreateDeviceNo();
    await _api.auth.addAccountByDeviceNo(deviceNo, accountId, password);
    return switchAccountOnDevice(accountId: accountId);
  }

  Future<void> logout() async {
    final deviceNo = await _accountRepository.getOrCreateDeviceNo();
    await _api.auth.logout(deviceNo);
  }

  /// Resets trade MQTT credentials for this device before reconnecting.
  Future<void> initMqttKey() async {
    final deviceNo = await _accountRepository.getOrCreateDeviceNo();
    await _api.auth.initMqttKey(deviceNo);
  }
}
