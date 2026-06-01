import 'package:ap_securities/features/profile/presentation/widgets/settings_page_colors.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:ap_securities/providers/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Picks app UI language; choice is persisted via [appLocaleProvider].
class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  static bool _isSimplifiedChinese(Locale? locale) =>
      locale?.languageCode == 'zh' &&
      (locale?.countryCode == null || locale!.countryCode!.isEmpty);

  static bool _isTraditionalChinese(Locale? locale) =>
      locale?.languageCode == 'zh' && locale?.countryCode == 'TW';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(appLocaleProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Color(0xFF2D8BFF),
          ),
        ),
        title: Text(
          l10n.settingsLanguageTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: SettingsPageColors.title,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: SettingsPageColors.divider,
          ),
        ),
      ),
      body: ListView(
        children: [
          _LanguageTile(
            title: l10n.settingsLanguageFollowSystem,
            selected: selected == null,
            onTap: () => _apply(context, ref, null),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: SettingsPageColors.divider,
          ),
          _LanguageTile(
            title: l10n.settingsLanguageEnglish,
            selected: selected?.languageCode == 'en',
            onTap: () => _apply(context, ref, const Locale('en')),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: SettingsPageColors.divider,
          ),
          _LanguageTile(
            title: l10n.settingsLanguageChineseSimplified,
            selected: _isSimplifiedChinese(selected),
            onTap: () => _apply(context, ref, const Locale('zh')),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: SettingsPageColors.divider,
          ),
          _LanguageTile(
            title: l10n.settingsLanguageChineseTraditional,
            selected: _isTraditionalChinese(selected),
            onTap: () => _apply(context, ref, const Locale('zh', 'TW')),
          ),
        ],
      ),
    );
  }

  Future<void> _apply(
    BuildContext context,
    WidgetRef ref,
    Locale? locale,
  ) async {
    await ref.read(appLocaleProvider.notifier).setLocale(locale);
    if (context.mounted) context.pop();
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: SettingsPageColors.title,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check, color: Color(0xFF2D8BFF))
          : null,
      onTap: onTap,
    );
  }
}
