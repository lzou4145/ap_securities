/// Flavor selected by each `main_*.dart` entrypoint.
enum AppEnvironment {
  development,
  staging,
  production,
}

extension AppEnvironmentConfig on AppEnvironment {
  String get apiBaseUrl => 'https://appapi.nplus.top/';

  /// Router diagnostics (debug logs from the router package).
  bool get enableVerboseLogging => switch (this) {
        AppEnvironment.production => false,
        _ => true,
      };

  /// Full HTTP body logging (enabled on development only).
  bool get enableNetworkTrafficLogging => switch (this) {
        AppEnvironment.development => true,
        _ => false,
      };
}
