import 'package:ap_securities/core/assets/app_icons.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:ap_securities/providers/app_shell_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Chart branch — full-bleed TradingView, no shell app bar.
const int kChartShellBranchIndex = 1;

/// Market branch — owns its own app bar (品种详情).
const int kMarketShellBranchIndex = 0;

/// Trade branch — owns P/L header and positions (no shell app bar).
const int kTradeShellBranchIndex = 2;

/// History branch — owns period filter header (no shell app bar).
const int kHistoryShellBranchIndex = 3;

/// Settings branch — owns its own app bar.
const int kSettingsShellBranchIndex = 4;

class MainShellPage extends ConsumerStatefulWidget {
  const MainShellPage({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends ConsumerState<MainShellPage> {
  static const double _navIconSize = 26;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setShellBranchIndex(ref, widget.navigationShell.currentIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final navigationShell = widget.navigationShell;
    final index = navigationShell.currentIndex;
    final theme = Theme.of(context);
    final showAppBar = index != kChartShellBranchIndex &&
        index != kMarketShellBranchIndex &&
        index != kTradeShellBranchIndex &&
        index != kHistoryShellBranchIndex &&
        index != kSettingsShellBranchIndex;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: showAppBar
          ? AppBar(
              title: Text(_titleForIndex(l10n, index)),
            )
          : null,
      body: navigationShell,
      bottomNavigationBar: NavigationBarTheme(
        data: theme.navigationBarTheme.copyWith(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? const Color(0xFF017FF7)
                  : theme.colorScheme.onSurfaceVariant,
            );
          }),
        ),
        child: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: index,
          onDestinationSelected: (selectedIndex) {
            setShellBranchIndex(ref, selectedIndex);
            navigationShell.goBranch(selectedIndex);
          },
          destinations: [
            NavigationDestination(
              icon: _navIcon(AppIcons.icTabMarket, l10n.navMarket),
              selectedIcon: _navIcon(AppIcons.icTabMarketSel, l10n.navMarket),
              label: l10n.navMarket,
            ),
            NavigationDestination(
              icon: _navIcon(AppIcons.icTabChart, l10n.navChart),
              selectedIcon: _navIcon(AppIcons.icTabChartSel, l10n.navChart),
              label: l10n.navChart,
            ),
            NavigationDestination(
              icon: _navIcon(AppIcons.icTabTrade, l10n.navTrade),
              selectedIcon: _navIcon(AppIcons.icTabTradeSel, l10n.navTrade),
              label: l10n.navTrade,
            ),
            NavigationDestination(
              icon: _navIcon(AppIcons.icTabHistory, l10n.navPortfolio),
              selectedIcon:
                  _navIcon(AppIcons.icTabHistorySel, l10n.navPortfolio),
              label: l10n.navPortfolio,
            ),
            NavigationDestination(
              icon: _navIcon(AppIcons.icTabSettings, l10n.navProfile),
              selectedIcon:
                  _navIcon(AppIcons.icTabSettingsSel, l10n.navProfile),
              label: l10n.navProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(String assetPath, String semanticLabel) {
    return Semantics(
      label: semanticLabel,
      child: Image.asset(
        assetPath,
        width: _navIconSize,
        height: _navIconSize,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
      ),
    );
  }

  String _titleForIndex(AppLocalizations l10n, int index) {
    switch (index) {
      case 0:
        return l10n.tabMarketTitle;
      case 1:
        return l10n.tabChartTitle;
      case 2:
        return l10n.tabTradeTitle;
      case 3:
        return l10n.tabPortfolioTitle;
      case 4:
      default:
        return l10n.tabProfileTitle;
    }
  }
}
