import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/features/chart/providers/chart_providers.dart';
import 'package:ap_securities/providers/app_shell_theme.dart';
import 'package:ap_securities/shell/view/main_shell_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Switches to the chart tab and loads MQTT history for [symbol].
void openChartTab(BuildContext context, WidgetRef ref, String symbol) {
  setShellBranchIndex(ref, kChartShellBranchIndex);
  StatefulNavigationShell.maybeOf(context)?.goBranch(kChartShellBranchIndex);
  context.go(AppRoutes.chart);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(chartControllerProvider.notifier).openSymbol(symbol);
  });
}
