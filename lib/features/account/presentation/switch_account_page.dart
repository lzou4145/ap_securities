import 'package:ap_securities/core/network/api_exception.dart';
import 'package:ap_securities/core/ui/app_toast.dart';
import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/features/account/presentation/widgets/account_list_row.dart';
import 'package:ap_securities/features/account/presentation/widgets/account_page_colors.dart';
import 'package:ap_securities/features/account/providers/account_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SwitchAccountPage extends ConsumerStatefulWidget {
  const SwitchAccountPage({super.key});

  @override
  ConsumerState<SwitchAccountPage> createState() => _SwitchAccountPageState();
}

class _SwitchAccountPageState extends ConsumerState<SwitchAccountPage> {
  String? _switchingLocalId;

  Future<void> _onSwitchAccount(String localAccountId) async {
    if (_switchingLocalId != null) return;

    final l10n = context.l10n;

    setState(() => _switchingLocalId = localAccountId);
    try {
      await ref
          .read(accountSessionProvider.notifier)
          .switchToAccount(localAccountId);
    } on ApiException catch (e) {
      if (!mounted) return;
      final message = e.message.trim();
      context.showAppMessage(
        message.isNotEmpty ? message : l10n.loginFailedSnackbar,
        variant: AppMessageVariant.error,
      );
    } finally {
      if (mounted) setState(() => _switchingLocalId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sessionAsync = ref.watch(accountSessionProvider);

    final switching = _switchingLocalId != null;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: switching ? null : () => context.pop(),
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: AccountPageColors.primaryBlue,
              ),
            ),
            title: Text(
              l10n.switchAccountTitle,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AccountPageColors.title,
              ),
            ),
            actions: [
              TextButton(
                onPressed: switching
                    ? null
                    : () => context.push(AppRoutes.profileAddAccount),
                child: Text(
                  l10n.switchAccountAddAction,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AccountPageColors.primaryBlue,
                  ),
                ),
              ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(
                height: 1,
                thickness: 1,
                color: AccountPageColors.divider,
              ),
            ),
          ),
          body: sessionAsync.when(
            data: (session) {
              if (session.accounts.isEmpty) {
                return Center(
                  child: Text(
                    l10n.switchAccountEmpty,
                    style: const TextStyle(color: AccountPageColors.subtitle),
                  ),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: session.accounts.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 86,
                  color: AccountPageColors.divider,
                ),
                itemBuilder: (context, index) {
                  final account = session.accounts[index];
                  final isActive = session.activeAccountId == account.id;
                  final switching = _switchingLocalId == account.id;
                  final displayName = account.accountName.isNotEmpty
                      ? account.accountName
                      : account.accountId;
                  return AccountListRow(
                    displayName: displayName,
                    isActive: isActive,
                    switching: switching,
                    onSwitch: isActive || _switchingLocalId != null
                        ? null
                        : () => _onSwitchAccount(account.id),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
          ),
        ),
        if (switching)
          Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: Colors.white.withValues(alpha: 0.72),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
