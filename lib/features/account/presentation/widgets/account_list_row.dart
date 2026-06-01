import 'package:ap_securities/features/account/presentation/widgets/account_page_colors.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';

class AccountListRow extends StatelessWidget {
  const AccountListRow({
    required this.displayName,
    required this.isActive,
    this.onSwitch,
    this.switching = false,
    super.key,
  });

  final String displayName;
  final bool isActive;
  final VoidCallback? onSwitch;
  final bool switching;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AccountPageColors.avatarBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 28,
              color: AccountPageColors.avatarIcon,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              displayName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AccountPageColors.title,
              ),
            ),
          ),
          if (onSwitch != null)
            switching
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : TextButton.icon(
                    onPressed: onSwitch,
                    icon: const Icon(
                      Icons.swap_horiz,
                      size: 18,
                      color: AccountPageColors.primaryBlue,
                    ),
                    label: Text(
                      l10n.switchAccountAction,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AccountPageColors.primaryBlue,
                      ),
                    ),
                  ),
        ],
      ),
    );
  }
}
