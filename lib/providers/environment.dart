import 'package:ap_securities/core/config/app_environment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Must be overridden in `ProviderScope` from each `main_*.dart`.
final environmentProvider = Provider<AppEnvironment>(
  (ref) => throw StateError(
    'environmentProvider is not overridden. Wrap the app with '
    'ProviderScope(overrides: [environmentProvider.overrideWithValue(...)]).',
  ),
);
