import 'package:ap_securities/app/app.dart';
import 'package:ap_securities/core/config/app_environment.dart';
import 'package:ap_securities/features/account/domain/stored_account.dart';
import 'package:ap_securities/features/account/providers/account_providers.dart';
import 'package:ap_securities/providers/auth.dart';
import 'package:ap_securities/providers/environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'signed_in_auth_notifier.dart';

/// Resolves immediately with no stored accounts (avoids startup route stalling tests).
class _EmptyAccountSessionNotifier extends AccountSessionNotifier {
  @override
  Future<AccountSession> build() async => const AccountSession(accounts: []);
}

extension PumpAppHarness on WidgetTester {
  /// Boots the full `App` with Riverpod + router. Uses development flavor and
  /// a signed-in session by default so shell tests stay simple.
  Future<void> pumpApp({
    AppEnvironment environment = AppEnvironment.development,
    bool signedIn = true,
  }) async {
    platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(platformDispatcher.clearLocaleTestValue);
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    await pumpWidget(
      ProviderScope(
        overrides: [
          environmentProvider.overrideWithValue(environment),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          if (!signedIn)
            accountSessionProvider.overrideWith(_EmptyAccountSessionNotifier.new),
          if (signedIn)
            authNotifierProvider.overrideWith(SignedInAuthNotifier.new),
        ],
        child: const App(),
      ),
    );
  }
}
