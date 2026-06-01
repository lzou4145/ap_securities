import 'package:ap_securities/core/network/api_exception.dart';
import 'package:ap_securities/core/ui/app_toast.dart';
import 'package:ap_securities/features/market/domain/trading_symbol_candidate.dart';
import 'package:ap_securities/features/market/domain/trading_symbol_category.dart';
import 'package:ap_securities/features/market/market_symbol_navigation.dart';
import 'package:ap_securities/features/market/presentation/widgets/add_trading_symbol_catalog_row.dart';
import 'package:ap_securities/features/market/presentation/widgets/market_page_colors.dart';
import 'package:ap_securities/features/market/providers/market_providers.dart';
import 'package:ap_securities/features/market/providers/market_watchlist_notifier.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddTradingSymbolListPage extends ConsumerStatefulWidget {
  const AddTradingSymbolListPage({required this.type, super.key});

  final String type;

  @override
  ConsumerState<AddTradingSymbolListPage> createState() =>
      _AddTradingSymbolListPageState();
}

class _AddTradingSymbolListPageState
    extends ConsumerState<AddTradingSymbolListPage> {
  final _addingIds = <int>{};

  Future<void> _onAddSymbol(TradingSymbolCandidate candidate) async {
    if (_addingIds.contains(candidate.varietyId)) return;

    setState(() => _addingIds.add(candidate.varietyId));
    final l10n = context.l10n;

    try {
      await ref
          .read(marketWatchlistProvider.notifier)
          .addVariety(candidate.varietyId);
    } on ApiException catch (e) {
      if (!mounted) return;
      context.showAppMessage(
        e.message.trim().isNotEmpty ? e.message : l10n.loginFailedSnackbar,
        variant: AppMessageVariant.error,
      );
    } finally {
      if (mounted) {
        setState(() => _addingIds.remove(candidate.varietyId));
      }
    }
  }

  void _openDetail(TradingSymbolCandidate candidate) {
    openTradingSymbolDetail(context, variety: candidate.variety);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final category = TradingSymbolCategoryType.fromApiType(widget.type);
    final title = category?.title(l10n) ?? widget.type;
    final catalogAsync = ref.watch(
      filteredTradingSymbolCatalogByTypeProvider(widget.type),
    );

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
          title,
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
      body: catalogAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$e', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        ref.invalidate(
                          tradingSymbolCatalogByTypeProvider(widget.type),
                        );
                      },
                      child: Text(l10n.retryButton),
                    ),
                  ],
                ),
              ),
              data: (catalog) {
                if (catalog.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.marketAddSymbolEmpty,
                      style: const TextStyle(
                        fontSize: 15,
                        color: MarketPageColors.secondaryText,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: catalog.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: MarketPageColors.divider,
                  ),
                  itemBuilder: (context, index) {
                    final row = catalog[index];
                    return AddTradingSymbolCatalogRow(
                      candidate: row,
                      adding: _addingIds.contains(row.varietyId),
                      onAddTap: () => _onAddSymbol(row),
                      onRowTap: () => _openDetail(row),
                    );
                  },
                );
              },
            ),
    );
  }
}
