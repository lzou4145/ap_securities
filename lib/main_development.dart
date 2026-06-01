import 'package:ap_securities/app/app.dart';
import 'package:ap_securities/bootstrap.dart';
import 'package:ap_securities/core/config/app_environment.dart';
import 'package:ap_securities/features/account/providers/account_providers.dart';
import 'package:ap_securities/providers/environment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  bootstrap(
    (sharedPreferences) => ProviderScope(
      overrides: [
        environmentProvider.overrideWithValue(AppEnvironment.development),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const App(),
    ),
  );
}
