import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Confirm before signing out from the settings screen.
Future<bool> showLogoutConfirmDialog({
  required BuildContext context,
  required AppLocalizations l10n,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black38,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.logoutConfirmMessage,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _LogoutDialogButton(
                      label: l10n.tradePendingCancel,
                      foregroundColor: const Color(0xFF1A1A1A),
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _LogoutDialogButton(
                      label: l10n.logoutButton,
                      foregroundColor: const Color(0xFFE53935),
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  return result ?? false;
}

class _LogoutDialogButton extends StatelessWidget {
  const _LogoutDialogButton({
    required this.label,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE5E5EA),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: 44,
          child: Center(
            child: Text(
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
