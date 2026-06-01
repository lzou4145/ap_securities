import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDeviceNoKey = 'app_device_no_v1';

/// Resolves a stable `device_no` for this physical device / install.
///
/// Mobile uses OS-level identifiers ([AndroidDeviceInfo.id] /
/// [IosDeviceInfo.identifierForVendor]). Other platforms fall back to a
/// one-time random id persisted in [SharedPreferences].
class DeviceNoService {
  DeviceNoService(this._prefs);

  final SharedPreferences _prefs;

  Future<String> getDeviceNo() async {
    final cached = _prefs.getString(_kDeviceNoKey);
    if (cached != null && cached.isNotEmpty && !_isLegacyGeneratedId(cached)) {
      return cached;
    }

    final resolved = await _resolvePlatformDeviceId() ?? _randomDeviceNo();
    await _prefs.setString(_kDeviceNoKey, resolved);
    return resolved;
  }

  static bool _isLegacyGeneratedId(String value) =>
      value.startsWith('flutter_');

  Future<String?> _resolvePlatformDeviceId() async {
    final plugin = DeviceInfoPlugin();
    if (kIsWeb) {
      final web = await plugin.webBrowserInfo;
      final vendor = web.vendor ?? '';
      final userAgent = web.userAgent ?? '';
      if (vendor.isNotEmpty || userAgent.isNotEmpty) {
        return 'web_${_hash('${vendor}_$userAgent')}';
      }
      return null;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final info = await plugin.androidInfo;
        final androidId = info.id;
        return androidId.isNotEmpty ? androidId : null;
      case TargetPlatform.iOS:
        final info = await plugin.iosInfo;
        return info.identifierForVendor;
      case TargetPlatform.macOS:
        final info = await plugin.macOsInfo;
        final guid = info.systemGUID;
        return guid != null && guid.isNotEmpty ? guid : null;
      case TargetPlatform.windows:
        final info = await plugin.windowsInfo;
        final deviceId = info.deviceId;
        return deviceId.isNotEmpty ? deviceId : null;
      case TargetPlatform.linux:
        final info = await plugin.linuxInfo;
        final machineId = info.machineId;
        return machineId != null && machineId.isNotEmpty ? machineId : null;
      case TargetPlatform.fuchsia:
        return null;
    }
  }

  static String _randomDeviceNo() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';
  }

  static String _hash(String input) {
    var hash = 0;
    for (final unit in input.codeUnits) {
      hash = 0x1fffffff & (hash + unit);
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      hash ^= hash >> 6;
    }
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash ^= hash >> 11;
    hash = 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
    return hash.abs().toRadixString(16);
  }
}
