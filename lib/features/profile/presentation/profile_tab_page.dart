import 'package:ap_securities/core/assets/app_icons.dart';
import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/core/ui/app_toast.dart';
import 'package:ap_securities/features/profile/presentation/widgets/logout_confirm_dialog.dart';
import 'package:ap_securities/features/profile/presentation/widgets/settings_menu_row.dart';
import 'package:ap_securities/features/profile/presentation/widgets/settings_page_colors.dart';
import 'package:ap_securities/features/account/providers/account_providers.dart';
import 'package:ap_securities/features/profile/providers/profile_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:ap_securities/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileTabPage extends ConsumerWidget {
  const ProfileTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final sessionAsync = ref.watch(accountSessionProvider);
    final summary = ref.watch(profileSummaryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.tabProfileTitle,
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
      body: sessionAsync.when(
        data: (_) {
          if (summary == null) {
            return Center(child: Text(l10n.modulePlaceholder));
          }
          return _SettingsBody(
            accountName: summary.accountName,
            accountId: summary.accountId,
            l10n: l10n,
            onAccountTap: () => context.push(AppRoutes.profileAccounts),
            onLanguageTap: () => context.push(AppRoutes.profileLanguage),
            onAnnouncementsTap: () =>
                context.push(AppRoutes.profileAnnouncements),
            onBackendLinkTap: () => context.push(AppRoutes.profileBackendLink),
            onPersonalizedTradingTap: () =>
                context.push(AppRoutes.profilePersonalizedTrading),
            onLogout: () async {
              final confirmed = await showLogoutConfirmDialog(
                context: context,
                l10n: l10n,
              );
              if (!confirmed || !context.mounted) return;
              await ref.read(authNotifierProvider.notifier).signOut();
            },
            onMenuTap: (message) => context.showAppMessage(message),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$e', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(accountSessionProvider),
                child: Text(l10n.retryButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({
    required this.accountName,
    required this.accountId,
    required this.l10n,
    required this.onAccountTap,
    required this.onLanguageTap,
    required this.onAnnouncementsTap,
    required this.onBackendLinkTap,
    required this.onPersonalizedTradingTap,
    required this.onLogout,
    required this.onMenuTap,
  });

  final String accountName;
  final String accountId;
  final AppLocalizations l10n;
  final VoidCallback onAccountTap;
  final VoidCallback onLanguageTap;
  final VoidCallback onAnnouncementsTap;
  final VoidCallback onBackendLinkTap;
  final VoidCallback onPersonalizedTradingTap;
  final Future<void> Function() onLogout;
  final void Function(String message) onMenuTap;

  @override
  Widget build(BuildContext context) {
    final coming = l10n.settingsFeatureComingSoon;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _UserHeader(
          accountName: accountName,
          accountIdLine: l10n.profileAccountIdLine(accountId),
          onTap: onAccountTap,
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: SettingsPageColors.divider,
        ),
        SettingsMenuRow(
          iconAsset: AppIcons.icSettingsPersonalizedTrading,
          label: l10n.settingsPersonalizedTrading,
          onTap: onPersonalizedTradingTap,
          showDivider: true,
        ),
        SettingsMenuRow(
          iconAsset: AppIcons.icSettingsSwitchLanguage,
          label: l10n.settingsSwitchLanguage,
          onTap: onLanguageTap,
          showDivider: true,
        ),
        SettingsMenuRow(
          leadingIcon: Icons.notifications_outlined,
          label: l10n.settingsViewAnnouncements,
          onTap: onAnnouncementsTap,
          showDivider: true,
        ),
        SettingsMenuRow(
          iconAsset: AppIcons.icSettingsCustomerService,
          label: l10n.settingsCustomerService,
          onTap: () => onMenuTap(coming),
          showDivider: true,
        ),
        SettingsMenuRow(
          iconAsset: AppIcons.icSettingsBackendLink,
          label: l10n.settingsBackendLink,
          onTap: onBackendLinkTap,
          showDivider: false,
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _LogoutButton(
            label: l10n.logoutButton,
            onPressed: onLogout,
          ),
        ),
      ],
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({
    required this.accountName,
    required this.accountIdLine,
    required this.onTap,
  });

  final String accountName;
  final String accountIdLine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: SettingsPageColors.avatarBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: SettingsPageColors.avatarIcon,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      accountName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: SettingsPageColors.title,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      accountIdLine,
                      style: const TextStyle(
                        fontSize: 14,
                        color: SettingsPageColors.subtitle,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 22,
                color: SettingsPageColors.chevron,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SettingsPageColors.logoutBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => onPressed(),
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.power_settings_new,
                size: 20,
                color: SettingsPageColors.logoutFg,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: SettingsPageColors.logoutFg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
