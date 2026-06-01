import 'package:ap_securities/features/portfolio/domain/holding_row.dart';
import 'package:ap_securities/features/portfolio/providers/portfolio_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PortfolioTabPage extends ConsumerWidget {
  const PortfolioTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final holdings = ref.watch(portfolioHoldingsProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: holdings.when(
        data: (rows) => _HoldingsList(rows: rows, l10n: l10n),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _PortfolioError(
          message: '$e',
          onRetry: () => ref.invalidate(portfolioHoldingsProvider),
        ),
      ),
    );
  }
}

class _HoldingsList extends StatelessWidget {
  const _HoldingsList({required this.rows, required this.l10n});

  final List<HoldingRow> rows;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.portfolioSectionTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final h = rows[i];
              final pct = h.pnlPercent * 100;
              final color = h.pnlPercent >= 0 ? Colors.red : Colors.green;
              return ListTile(
                title: Text(h.name),
                subtitle: Text('${h.code} · ${h.quantity}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(h.marketValue.toStringAsFixed(2)),
                    Text(
                      '${l10n.changePercentLabel} ${pct >= 0 ? '+' : ''}'
                      '${pct.toStringAsFixed(2)}%',
                      style: TextStyle(color: color, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PortfolioError extends StatelessWidget {
  const _PortfolioError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: Text(l10n.retryButton)),
        ],
      ),
    );
  }
}
