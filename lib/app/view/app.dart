import 'package:ap_securities/app/theme/app_theme.dart';
import 'package:ap_securities/core/auth/session_expired_binder.dart';
import 'package:ap_securities/core/mqtt/mqtt_network_watch_provider.dart';
import 'package:ap_securities/features/market/providers/market_tick_mqtt_providers.dart';
import 'package:ap_securities/features/trade/providers/trade_mqtt_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:ap_securities/providers/account_scoped_data_refresh.dart';
import 'package:ap_securities/providers/app_locale.dart';
import 'package:ap_securities/providers/app_shell_theme.dart';
import 'package:ap_securities/providers/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(accountScopedDataRefreshProvider);
    ref.watch(marketTickMqttLifecycleProvider);
    ref.watch(tradeMqttLifecycleProvider);
    ref.watch(mqttNetworkWatchProvider);
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(appLocaleProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    return SessionExpiredBinder(
      child: MaterialApp.router(
        routerConfig: router,
        locale: locale,
        onGenerateTitle: (context) => context.l10n.appTitle,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
