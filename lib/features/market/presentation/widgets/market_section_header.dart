import 'package:ap_securities/features/market/presentation/widgets/market_page_colors.dart';
import 'package:flutter/material.dart';

class MarketSectionHeader extends StatelessWidget {
  const MarketSectionHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: MarketPageColors.secondaryText,
        ),
      ),
    );
  }
}
