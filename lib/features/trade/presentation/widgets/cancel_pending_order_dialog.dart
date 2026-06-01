import 'package:ap_securities/features/market/domain/market_price_format.dart';
import 'package:ap_securities/features/trade/domain/pending_order.dart';
import 'package:ap_securities/features/trade/domain/trade_order_modify_context.dart';
import 'package:ap_securities/features/trade/presentation/trade_formatters.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Second-step confirm before cancelling a pending order.
Future<bool> showCancelPendingOrderDialog({
  required BuildContext context,
  required AppLocalizations l10n,
  required PendingOrder order,
  required int decimalPlace,
}) async {
  final kindLabel = order.kind.kindLabel(l10n);
  final lot = TradeFormatters.volume(order.lot);
  final price = formatMarketPrice(order.limitPrice, decimalPlace: decimalPlace);
  final message = l10n.tradePendingCancelConfirmMessage(
    order.id,
    order.symbol,
    kindLabel,
    lot,
    price,
  );

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
                message,
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
                    child: _CancelDialogButton(
                      label: l10n.tradePendingCancel,
                      foregroundColor: const Color(0xFF1A1A1A),
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CancelDialogButton(
                      label: l10n.tradeOrderDelete,
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

class _CancelDialogButton extends StatelessWidget {
  const _CancelDialogButton({
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
