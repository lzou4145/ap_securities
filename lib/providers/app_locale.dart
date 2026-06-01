import 'package:ap_securities/features/account/providers/account_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kAppLocaleTag = 'app_locale_tag_v1';
const _kLegacyLocaleLanguageCode = 'app_locale_language_code_v1';

/// Encodes [Locale] as `en`, `zh`, or `zh_TW`.
String encodeLocaleTag(Locale locale) {
  final country = locale.countryCode;
  if (country != null && country.isNotEmpty) {
    return '${locale.languageCode}_$country';
  }
  return locale.languageCode;
}

Locale decodeLocaleTag(String tag) {
  final parts = tag.split('_');
  if (parts.length >= 2) {
    return Locale(parts[0], parts.sublist(1).join('_'));
  }
  return Locale(tag);
}

class AppLocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final prefs = ref.read(sharedPreferencesProvider);
    var tag = prefs.getString(_kAppLocaleTag);
    if (tag == null || tag.isEmpty) {
      final legacy = prefs.getString(_kLegacyLocaleLanguageCode);
      if (legacy == null || legacy.isEmpty) return null;
      tag = legacy;
    }
    return decodeLocaleTag(tag);
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(_kAppLocaleTag);
    } else {
      await prefs.setString(_kAppLocaleTag, encodeLocaleTag(locale));
    }
    state = locale;
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale?>(
  AppLocaleNotifier.new,
);
