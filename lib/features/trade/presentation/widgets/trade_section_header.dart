import 'package:ap_securities/features/trade/presentation/trade_page_colors.dart';
import 'package:flutter/material.dart';

class TradeSectionHeader extends StatelessWidget {
  const TradeSectionHeader({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TradePageColors.sectionHeaderBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: TradePageColors.title,
        ),
      ),
    );
  }
}
