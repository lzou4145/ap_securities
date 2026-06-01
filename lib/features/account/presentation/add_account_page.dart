import 'package:ap_securities/core/network/api_exception.dart';
import 'package:ap_securities/core/ui/app_toast.dart';
import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/features/account/presentation/widgets/account_page_colors.dart';
import 'package:ap_securities/features/account/providers/account_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddAccountPage extends ConsumerStatefulWidget {
  const AddAccountPage({super.key});

  @override
  ConsumerState<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends ConsumerState<AddAccountPage> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  var _submitting = false;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
            color: AccountPageColors.primaryBlue,
          ),
        ),
        title: Text(
          l10n.addAccountTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AccountPageColors.title,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AccountPageColors.divider,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 28),
          Text(
            l10n.addAccountSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AccountPageColors.title,
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.addAccountIdLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AccountPageColors.title,
                  ),
                ),
                const SizedBox(height: 8),
                _AccountField(
                  controller: _accountController,
                  hint: l10n.addAccountIdHint,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.addAccountPasswordLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AccountPageColors.title,
                  ),
                ),
                const SizedBox(height: 8),
                _AccountField(
                  controller: _passwordController,
                  hint: l10n.addAccountPasswordHint,
                  obscureText: true,
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              children: [
                Expanded(
                  child: _CapsuleButton(
                    label: l10n.addAccountCancel,
                    backgroundColor: AccountPageColors.cancelBg,
                    foregroundColor: AccountPageColors.primaryBlue,
                    onPressed: _submitting ? null : () => context.pop(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _CapsuleButton(
                    label: l10n.addAccountConfirm,
                    backgroundColor: AccountPageColors.primaryBlue,
                    foregroundColor: Colors.white,
                    loading: _submitting,
                    onPressed: _submitting ? null : _onConfirm,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onConfirm() async {
    final l10n = context.l10n;

    setState(() => _submitting = true);
    try {
      final ok = await ref.read(accountSessionProvider.notifier).addAccount(
            account: _accountController.text,
            password: _passwordController.text,
          );
      if (!mounted) return;
      if (!ok) {
        context.showAppMessage(l10n.loginInvalidCredentialsSnackbar);
        return;
      }
      context.go(AppRoutes.profileAccounts);
    } on ApiException catch (e) {
      if (!mounted) return;
      final message = e.message.trim();
      context.showAppMessage(
        message.isNotEmpty ? message : l10n.loginFailedSnackbar,
        variant: AppMessageVariant.error,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _AccountField extends StatelessWidget {
  const _AccountField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 15, color: AccountPageColors.title),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 15, color: AccountPageColors.hint),
        filled: true,
        fillColor: AccountPageColors.fieldBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CapsuleButton extends StatelessWidget {
  const _CapsuleButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.loading = false,
    this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 48,
          child: Center(
            child: loading
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: foregroundColor,
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: foregroundColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
