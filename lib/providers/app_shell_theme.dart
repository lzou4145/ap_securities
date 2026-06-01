import 'package:ap_securities/shell/view/main_shell_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current bottom-nav branch; drives global [ThemeMode].
final shellBranchIndexProvider = StateProvider<int>((ref) => 0);

/// Chart tab K-line theme (toggled from chart app bar).
final chartThemeDarkProvider = StateProvider<bool>((ref) => true);

/// Chart tab theme follows [chartThemeDarkProvider]; other tabs use light.
final appThemeModeProvider = Provider<ThemeMode>((ref) {
  final index = ref.watch(shellBranchIndexProvider);
  if (index == kChartShellBranchIndex) {
    return ref.watch(chartThemeDarkProvider)
        ? ThemeMode.dark
        : ThemeMode.light;
  }
  return ThemeMode.light;
});

void setShellBranchIndex(WidgetRef ref, int index) {
  ref.read(shellBranchIndexProvider.notifier).state = index;
}
