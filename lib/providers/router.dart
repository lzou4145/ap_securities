import 'package:ap_securities/core/config/app_environment.dart';
import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/features/account/presentation/add_account_page.dart';
import 'package:ap_securities/features/account/presentation/switch_account_page.dart';
import 'package:ap_securities/features/announcements/presentation/announcement_detail_page.dart';
import 'package:ap_securities/features/announcements/presentation/announcements_list_page.dart';
import 'package:ap_securities/app/view/startup_page.dart';
import 'package:ap_securities/features/auth/presentation/login_page.dart';
import 'package:ap_securities/features/chart/presentation/chart_tab_page.dart';
import 'package:ap_securities/features/history/presentation/history_tab_page.dart';
import 'package:ap_securities/features/market/presentation/add_trading_symbol_list_page.dart';
import 'package:ap_securities/features/market/presentation/add_trading_symbol_page.dart';
import 'package:ap_securities/features/market/presentation/market_tab_page.dart';
import 'package:ap_securities/features/market/domain/trading_symbol_detail.dart';
import 'package:ap_securities/features/market/presentation/trading_symbol_detail_page.dart';
import 'package:ap_securities/features/personalized_trading/domain/follow_trader_args.dart';
import 'package:ap_securities/features/personalized_trading/presentation/follow_trader_page.dart';
import 'package:ap_securities/features/personalized_trading/presentation/personalized_trading_page.dart';
import 'package:ap_securities/features/personalized_trading/presentation/follow_details_page.dart';
import 'package:ap_securities/features/personalized_trading/presentation/single_provider_settings_page.dart';
import 'package:ap_securities/core/config/app_urls.dart';
import 'package:ap_securities/core/ui/in_app_web_page.dart';
import 'package:ap_securities/features/profile/presentation/language_settings_page.dart';
import 'package:ap_securities/features/profile/presentation/profile_tab_page.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:ap_securities/features/trade/presentation/trade_order_page.dart';
import 'package:ap_securities/features/trade/domain/order_info_query_type.dart';
import 'package:ap_securities/features/trade/domain/trade_order_success_variant.dart';
import 'package:ap_securities/features/trade/presentation/trade_order_success_page.dart';
import 'package:ap_securities/features/trade/presentation/trade_tab_page.dart';
import 'package:ap_securities/providers/auth.dart';
import 'package:ap_securities/providers/environment.dart';
import 'package:ap_securities/providers/go_router_refresh.dart';
import 'package:ap_securities/shell/view/main_shell_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouterProvider = Provider<GoRouter>((ref) {
  final env = ref.watch(environmentProvider);
  final refresh = ref.watch(goRouterRefreshProvider);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.startup,
    debugLogDiagnostics: env.enableVerboseLogging,
    refreshListenable: refresh,
    redirect: (context, state) {
      final path = state.matchedLocation;
      final onStartup = path == AppRoutes.startup;

      if (ref.read(authSessionLoadingProvider)) {
        if (!onStartup) return AppRoutes.startup;
        return null;
      }

      final auth = ref.read(authNotifierProvider);
      final onLogin = path == AppRoutes.login;
      if (auth is AuthStateSignedIn) {
        if (onLogin || onStartup) return AppRoutes.market;
        return null;
      }
      if (onStartup) return AppRoutes.login;
      if (!onLogin) return AppRoutes.login;
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        redirect: (_, __) => AppRoutes.startup,
      ),
      GoRoute(
        path: AppRoutes.startup,
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: StartupPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return MainShellPage(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.market,
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                  child: MarketTabPage(),
                ),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'add-symbols',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const AddTradingSymbolPage(),
                    routes: <RouteBase>[
                      GoRoute(
                        path: ':type',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) {
                          final type = state.pathParameters['type'] ?? '';
                          return AddTradingSymbolListPage(type: type);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'symbol/:symbol',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final extra = state.extra;
                      if (extra is! TradingSymbolDetail) {
                        throw StateError(
                          'TradingSymbolDetailPage requires '
                          'TradingSymbolDetail in GoRouterState.extra',
                        );
                      }
                      return TradingSymbolDetailPage(detail: extra);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.chart,
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                  child: ChartTabPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.trade,
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                  child: TradeTabPage(),
                ),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'order',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final symbol = state.uri.queryParameters['symbol'];
                      return TradeOrderPage(initialSymbol: symbol);
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'success',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) {
                          final orderId =
                              state.uri.queryParameters['order_id'] ?? '';
                          final infoType = int.tryParse(
                                state.uri.queryParameters['type'] ?? '',
                              ) ??
                              OrderInfoQueryType.pending;
                          final variant = TradeOrderSuccessVariantParsing
                              .fromQuery(state.uri.queryParameters['variant']);
                          return TradeOrderSuccessPage(
                            orderId: orderId,
                            infoType: infoType,
                            variant: variant,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.portfolio,
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                  child: HistoryTabPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                  child: ProfileTabPage(),
                ),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'accounts',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const SwitchAccountPage(),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'add',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => const AddAccountPage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'language',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const LanguageSettingsPage(),
                  ),
                  GoRoute(
                    path: 'backend-link',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => InAppWebPage(
                      title: context.l10n.settingsBackendLink,
                      initialUrl: AppUrls.adminH5,
                    ),
                  ),
                  GoRoute(
                    path: 'personalized-trading',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        const PersonalizedTradingPage(),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'follow-details',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => const FollowDetailsPage(),
                      ),
                      GoRoute(
                        path: 'single-settings',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) =>
                            const SingleProviderSettingsPage(),
                      ),
                      GoRoute(
                        path: 'follow',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) {
                          final params = state.uri.queryParameters;
                          final id = int.tryParse(
                                params['single_account_id'] ?? '',
                              ) ??
                              0;
                          return FollowTraderPage(
                            args: FollowTraderArgs(
                              singleAccountId: id,
                              accountName: params['name'] ?? '',
                              daysAmount: params['profit'] ?? '',
                              followWalletsTradeAmount:
                                  params['follow_balance'] ?? '',
                              followCommissionRate: int.tryParse(
                                    params['commission'] ?? '',
                                  ) ??
                                  0,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'announcements',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const AnnouncementsListPage(),
                    routes: <RouteBase>[
                      GoRoute(
                        path: ':id',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => AnnouncementDetailPage(
                          announcementId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
