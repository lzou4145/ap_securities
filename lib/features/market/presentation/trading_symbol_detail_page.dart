import 'package:ap_securities/features/market/domain/trading_symbol_detail.dart';
import 'package:ap_securities/features/market/presentation/widgets/market_page_colors.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';

class TradingSymbolDetailPage extends StatelessWidget {
  const TradingSymbolDetailPage({
    required this.detail,
    super.key,
  });

  final TradingSymbolDetail detail;

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
        foregroundColor: MarketPageColors.primaryBlue,
        iconTheme: const IconThemeData(color: MarketPageColors.primaryBlue),
        title: Text(
          detail.symbol,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: MarketPageColors.title,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: MarketPageColors.divider,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: detail.rows.length,
        itemBuilder: (context, index) {
          final row = detail.rows[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _labelForField(l10n, row.field),
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.3,
                      color: MarketPageColors.title,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _valueForRow(l10n, row),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.3,
                      color: MarketPageColors.title,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _labelForField(AppLocalizations l10n, SymbolDetailField field) {
    return switch (field) {
      SymbolDetailField.spread => l10n.symbolDetailSpread,
      SymbolDetailField.digits => l10n.symbolDetailDigits,
      SymbolDetailField.stopLevel => l10n.symbolDetailStopLevel,
      SymbolDetailField.contractSize => l10n.symbolDetailContractSize,
      SymbolDetailField.profitCalculation => l10n.symbolDetailProfitCalculation,
      SymbolDetailField.marginCalculation => l10n.symbolDetailMarginCalculation,
      SymbolDetailField.marginHedging => l10n.symbolDetailMarginHedging,
      SymbolDetailField.marginPercentage => l10n.symbolDetailMarginPercentage,
      SymbolDetailField.gtcPending => l10n.symbolDetailGtcPending,
      SymbolDetailField.swapType => l10n.symbolDetailSwapType,
      SymbolDetailField.swapLong => l10n.symbolDetailSwapLong,
      SymbolDetailField.swapShort => l10n.symbolDetailSwapShort,
    };
  }

  String _valueForRow(AppLocalizations l10n, TradingSymbolDetailRow row) {
    return switch (row.value) {
      'floating' => l10n.symbolDetailSpreadFloating,
      'yes' => l10n.symbolDetailYes,
      'forex' => 'Forex',
      _ => row.value,
    };
  }
}
