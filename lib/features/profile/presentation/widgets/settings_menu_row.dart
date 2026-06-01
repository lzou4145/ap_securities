import 'package:ap_securities/features/profile/presentation/widgets/settings_page_colors.dart';
import 'package:flutter/material.dart';

class SettingsMenuRow extends StatelessWidget {
  const SettingsMenuRow({
    required this.label,
    required this.onTap,
    required this.showDivider,
    this.iconAsset,
    this.leadingIcon,
    super.key,
  }) : assert(
          iconAsset != null || leadingIcon != null,
          'Provide iconAsset or leadingIcon',
        );

  final String? iconAsset;
  final IconData? leadingIcon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    if (leadingIcon != null)
                      Icon(
                        leadingIcon,
                        size: _iconSize,
                        color: SettingsPageColors.menuIcon,
                      )
                    else
                      Image.asset(
                        iconAsset!,
                        width: _iconSize,
                        height: _iconSize,
                        fit: BoxFit.contain,
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: SettingsPageColors.title,
                        ),
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
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: SettingsPageColors.divider,
          ),
      ],
    );
  }
}
