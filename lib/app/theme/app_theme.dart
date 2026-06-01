import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App-wide light / dark themes (dark used on chart tab).
abstract final class AppTheme {
  static const Color _seed = Color(0xFF0D47A1);
  static const Color _chartSurface = Color(0xFF131722);

  /// Status / nav bar icons for light backgrounds (e.g. trade order page).
  static const SystemUiOverlayStyle lightPageOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(seedColor: _seed);
    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.white,
      useMaterial3: true,
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A1A1A),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black12,
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
      // SnackBar is bottom-only in Flutter; prefer [AppToast] for in-app messages.
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData dark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF2D8BFF),
      onPrimary: Colors.white,
      secondary: Color(0xFF2D8BFF),
      onSecondary: Colors.white,
      error: Color(0xFFE53935),
      onError: Colors.white,
      surface: _chartSurface,
      onSurface: Colors.white,
      surfaceContainerHighest: Color(0xFF2A2E39),
      onSurfaceVariant: Color(0xFFB2B5BE),
    );
    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _chartSurface,
      useMaterial3: true,
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: _chartSurface,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: _chartSurface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black26,
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
      dividerColor: const Color(0xFF2A2E39),
    );
  }
}
