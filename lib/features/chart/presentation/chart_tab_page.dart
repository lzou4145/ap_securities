import 'dart:async';

import 'package:ap_securities/core/assets/app_icons.dart';
import 'package:ap_securities/core/assets/app_raster_icon.dart';
import 'package:ap_securities/core/assets/app_svg_icon.dart';
import 'package:ap_securities/core/mqtt/trade_mqtt_response.dart';
import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/features/chart/presentation/widgets/chart_quick_trade_panel.dart';
import 'package:ap_securities/features/chart/presentation/widgets/chart_resolution_sidebar.dart';
import 'package:ap_securities/features/chart/presentation/widgets/chart_tools_menus.dart';
import 'package:ap_securities/features/chart/domain/chart_series_type.dart';
import 'package:ap_securities/features/chart/presentation/widgets/chart_web_view.dart';
import 'package:ap_securities/features/chart/providers/chart_providers.dart';
import 'package:ap_securities/features/trade/application/instant_trade_action.dart';
import 'package:ap_securities/features/trade/providers/trade_mqtt_response_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:ap_securities/providers/app_shell_theme.dart';
import 'package:ap_securities/shell/view/main_shell_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Chart tab — TradingView Lightweight Charts fed by MQTT history.
class ChartTabPage extends ConsumerStatefulWidget {
  const ChartTabPage({super.key});

  @override
  ConsumerState<ChartTabPage> createState() => _ChartTabPageState();
}

class _ChartTabPageState extends ConsumerState<ChartTabPage> {
  final _chartWebViewKey = GlobalKey<ChartWebViewState>();

  var _wasActive = false;
  var _showWebView = false;
  var _resolutionPickerVisible = false;
  var _quickTradeVisible = false;

  bool _isChartTabActive(BuildContext context) {
    final shell = StatefulNavigationShell.maybeOf(context);
    return shell?.currentIndex == kChartShellBranchIndex;
  }

  void _openTradeOrder(BuildContext context, String? symbol) {
    if (symbol != null && symbol.isNotEmpty) {
      context.go(AppRoutes.tradeOrderWithSymbol(symbol));
    } else {
      context.go(AppRoutes.tradeOrder);
    }
  }

  void _scheduleShowWebView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        if (!mounted || !_isChartTabActive(context)) return;
        setState(() => _showWebView = true);
        ref.read(chartControllerProvider.notifier).ensureLoaded();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isActive = _isChartTabActive(context);

    if (isActive && !_wasActive) {
      _showWebView = false;
      _scheduleShowWebView();
    } else if (!isActive && _wasActive) {
      _showWebView = false;
      _resolutionPickerVisible = false;
      _quickTradeVisible = false;
    }
    _wasActive = isActive;

    ref.watch(tradeInstantOrderPendingProvider);
    ref.listen(tradeMqttLastResponseProvider, (previous, next) {
      final response = next?.response;
      if (response == null) return;
      if (response.operationType != TradeMqttOperationType.tradeBack) return;
      unawaited(
        finishInstantTradeResponse(
          ref: ref,
          context: context,
          l10n: l10n,
          response: response,
          pendingSymbol: ref.read(tradeInstantOrderPendingProvider),
          clearPending: () =>
              ref.read(tradeInstantOrderPendingProvider.notifier).state = null,
        ),
      );
    });

    final symbol =
        ref.watch(chartControllerProvider.select((state) => state.symbol));
    final loading =
        ref.watch(chartControllerProvider.select((state) => state.loading));
    final chartResolution =
        ref.watch(chartControllerProvider.select((state) => state.resolution));
    final chartSeriesType =
        ref.watch(chartControllerProvider.select((state) => state.seriesType));
    final title = symbol ?? l10n.tabChartTitle;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final chartDark = ref.watch(chartThemeDarkProvider);
    final isDarkChart = chartDark;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const SizedBox.shrink(),
        flexibleSpace: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                ChartResolutionNavButton(
                  label: chartResolution.displayLabel,
                  onTap: () => setState(
                    () => _resolutionPickerVisible = !_resolutionPickerVisible,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _ChartNavToolbar(
                    chartDark: chartDark,
                    chartSeriesType: chartSeriesType,
                    quickTradeVisible: _quickTradeVisible,
                    l10n: l10n,
                    onToggleTheme: () {
                      ref.read(chartThemeDarkProvider.notifier).state =
                          !chartDark;
                    },
                    onShowSeriesType: () => ChartToolsMenus.showSeriesTypeMenu(
                      context: context,
                      l10n: l10n,
                    ),
                    onShowIndicators: () => ChartToolsMenus.showIndicatorsMenu(
                      context: context,
                      l10n: l10n,
                    ),
                    onToggleQuickTrade: () => setState(
                      () => _quickTradeVisible = !_quickTradeVisible,
                    ),
                  ),
                ),
                if (loading) ...[
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                ChartResolutionNavButton(
                  label: l10n.navTrade,
                  onTap: () => _openTradeOrder(context, symbol),
                ),
              ],
            ),
          ),
        ),
      ),
      body: !isActive
          ? ColoredBox(color: colorScheme.surface)
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _showWebView
                          ? ChartWebView(
                              key: _chartWebViewKey,
                            )
                          : const Center(child: CircularProgressIndicator()),
                      if (_showWebView && symbol != null && symbol.isNotEmpty)
                        Positioned(
                          left: 12,
                          bottom: 34,
                          child: _ChartSymbolTitle(
                            title: title,
                            isDarkBackground: isDarkChart,
                          ),
                        ),
                      if (_resolutionPickerVisible)
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () => setState(
                              () => _resolutionPickerVisible = false,
                            ),
                            behavior: HitTestBehavior.opaque,
                            child: ColoredBox(
                              color: isDarkChart
                                  ? const Color(0x33000000)
                                  : const Color(0x1A000000),
                            ),
                          ),
                        ),
                      if (_resolutionPickerVisible)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ChartResolutionSidebar(
                            selected: chartResolution,
                            onSelected: (resolution) {
                              ref
                                  .read(chartControllerProvider.notifier)
                                  .setResolution(resolution);
                              setState(
                                () => _resolutionPickerVisible = false,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                if (_quickTradeVisible && symbol != null && symbol.isNotEmpty)
                  ChartQuickTradePanel(symbol: symbol),
              ],
            ),
    );
  }
}

/// Center tool icons — gap and padding shrink when horizontal space is tight.
class _ChartNavToolbar extends StatelessWidget {
  const _ChartNavToolbar({
    required this.chartDark,
    required this.chartSeriesType,
    required this.quickTradeVisible,
    required this.l10n,
    required this.onToggleTheme,
    required this.onShowSeriesType,
    required this.onShowIndicators,
    required this.onToggleQuickTrade,
  });

  final bool chartDark;
  final ChartSeriesType chartSeriesType;
  final bool quickTradeVisible;
  final AppLocalizations l10n;
  final VoidCallback onToggleTheme;
  final VoidCallback onShowSeriesType;
  final VoidCallback onShowIndicators;
  final VoidCallback onToggleQuickTrade;

  static double _gapForWidth(double width) {
    if (width < 156) return 2;
    if (width < 192) return 4;
    return 8;
  }

  static double _paddingHForWidth(double width) {
    if (width < 156) return 4;
    if (width < 192) return 6;
    return 10;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = _gapForWidth(constraints.maxWidth);
        final padH = _paddingHForWidth(constraints.maxWidth);
        final buttons = [
          _ChartNavToolButton(
            svgAsset: chartDark
                ? AppIcons.svgChatToolLightIcon
                : AppIcons.svgChatToolDarkIcon,
            iconColor: chartDark ? Colors.white : Colors.black,
            horizontalPadding: padH,
            tooltip: l10n.chartToolTheme,
            onTap: onToggleTheme,
          ),
          _ChartNavToolButton(
            svgAsset: chartSeriesType.iconAsset,
            horizontalPadding: padH,
            tooltip: l10n.chartToolChartType,
            onTap: onShowSeriesType,
          ),
          _ChartNavToolButton(
            svgAsset: AppIcons.svgChartToolIcon,
            horizontalPadding: padH,
            tooltip: l10n.chartToolIndicators,
            onTap: onShowIndicators,
          ),
          _ChartNavToolButton(
            svgAsset: AppIcons.svgChartToolLink,
            horizontalPadding: padH,
            tooltip: l10n.chartQuickTradeInstant,
            selected: quickTradeVisible,
            onTap: onToggleQuickTrade,
          ),
        ];

        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < buttons.length; i++) ...[
                if (i > 0) SizedBox(width: gap),
                buttons[i],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ChartNavToolButton extends StatelessWidget {
  const _ChartNavToolButton({
    required this.tooltip,
    required this.onTap,
    this.asset,
    this.svgAsset,
    this.iconColor,
    this.horizontalPadding = 10,
    this.selected = false,
  }) : assert(
          (asset != null) ^ (svgAsset != null),
          'Provide either asset or svgAsset',
        );

  final String? asset;
  final String? svgAsset;
  final Color? iconColor;
  final double horizontalPadding;
  final String tooltip;
  final VoidCallback onTap;
  final bool selected;

  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedIconColor =
        selected ? Colors.white : (iconColor ?? colorScheme.onSurface);

    final icon = svgAsset != null
        ? AppSvgIcon.asset(
            svgAsset!,
            size: _iconSize,
            color: resolvedIconColor,
          )
        : AppRasterIcon.asset(
            asset!,
            size: _iconSize,
            color: resolvedIconColor,
          );

    return Tooltip(
      message: tooltip,
      child: Material(
        color: selected ? const Color(0xFF2D8BFF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 6,
            ),
            child: SizedBox(
              width: _iconSize,
              height: _iconSize,
              child: Center(child: icon),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartSymbolTitle extends StatelessWidget {
  const _ChartSymbolTitle({
    required this.title,
    required this.isDarkBackground,
  });

  final String title;
  final bool isDarkBackground;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: isDarkBackground
            ? const Color(0xFFD1D4DC)
            : const Color(0xFF1A1A1A),
        shadows: isDarkBackground
            ? null
            : const [
                Shadow(
                  color: Color(0x66FFFFFF),
                  blurRadius: 4,
                ),
              ],
      ),
    );
  }
}
