import 'package:ap_securities/core/assets/app_icons.dart';
import 'package:ap_securities/core/theme/app_fonts.dart';
import 'package:ap_securities/features/market/domain/trading_symbol_candidate.dart';
import 'package:flutter/material.dart';

class AddTradingSymbolCatalogRow extends StatelessWidget {
  const AddTradingSymbolCatalogRow({
    required this.candidate,
    required this.adding,
    required this.onAddTap,
    required this.onRowTap,
    super.key,
  });

  final TradingSymbolCandidate candidate;
  final bool adding;
  final VoidCallback onAddTap;
  final VoidCallback onRowTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: adding ? null : onAddTap,
                behavior: HitTestBehavior.opaque,
                child: adding
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Image.asset(
                        AppIcons.icAdd,
                        width: 22,
                        height: 22,
                        fit: BoxFit.contain,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: InkWell(
                  onTap: onRowTap,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      candidate.symbol,
                      style: AppFonts.marketWatchlistSymbol(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
