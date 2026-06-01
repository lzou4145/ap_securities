import 'package:ap_securities/core/theme/app_fonts.dart';
import 'package:ap_securities/features/trade/presentation/trade_formatters.dart';
import 'package:flutter/material.dart';

class TradeSummaryRow extends StatelessWidget {
  const TradeSummaryRow({
    required this.label,
    required this.value,
    this.decimals = 2,
    super.key,
  });

  final String label;
  final double value;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppFonts.tradeSummaryLabel(),
            ),
          ),
          Text(
            TradeFormatters.amount(value, decimals: decimals),
            style: AppFonts.tradeSummaryValue(),
          ),
        ],
      ),
    );
  }
}
