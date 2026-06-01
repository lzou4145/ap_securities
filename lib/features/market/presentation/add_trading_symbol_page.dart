import 'dart:async';

import 'package:ap_securities/core/network/api_exception.dart';
import 'package:ap_securities/core/ui/app_toast.dart';
import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/features/market/domain/trading_symbol_candidate.dart';
import 'package:ap_securities/features/market/domain/trading_symbol_category.dart';
import 'package:ap_securities/features/market/market_symbol_navigation.dart';
import 'package:ap_securities/features/market/presentation/widgets/add_trading_symbol_catalog_row.dart';
import 'package:ap_securities/features/market/presentation/widgets/market_page_colors.dart';
import 'package:ap_securities/features/market/presentation/widgets/market_section_header.dart';
import 'package:ap_securities/features/market/providers/market_providers.dart';
import 'package:ap_securities/features/market/providers/market_watchlist_notifier.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Hub: categories or fuzzy search; category opens typed catalog list.
class AddTradingSymbolPage extends ConsumerStatefulWidget {
  const AddTradingSymbolPage({super.key});

  @override
  ConsumerState<AddTradingSymbolPage> createState() =>
      _AddTradingSymbolPageState();
}

class _AddTradingSymbolPageState extends ConsumerState<AddTradingSymbolPage> {
  final _searchController = TextEditingController();
  final _addingIds = <int>{};
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    if (value.trim().isEmpty) {
      ref.read(addSymbolSearchQueryProvider.notifier).state = '';
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(addSymbolSearchQueryProvider.notifier).state = value;
    });
  }

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
    final query = ref.watch(addSymbolSearchQueryProvider).trim();
    final isSearching = query.isNotEmpty;

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
          l10n.marketAddSymbolTitle,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: SizedBox(
              height: 36,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, value, _) {
                  return TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.2,
                      color: MarketPageColors.title,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: l10n.marketAddSymbolSearchHint,
                      hintStyle: const TextStyle(
                        fontSize: 15,
                        height: 1.2,
                        color: MarketPageColors.secondaryText,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                        color: MarketPageColors.secondaryText,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 36,
                        maxWidth: 36,
                        minHeight: 36,
                        maxHeight: 36,
                      ),
                      suffixIcon: value.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(
                                Icons.clear,
                                size: 18,
                                color: MarketPageColors.secondaryText,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            ),
                      filled: true,
                      fillColor: MarketPageColors.searchBg,
                      contentPadding: const EdgeInsets.only(bottom: 2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: isSearching
                ? _SearchResultsBody(
                    query: query,
                    addingIds: _addingIds,
                    onAddSymbol: _onAddSymbol,
                    onOpenDetail: _openDetail,
                  )
                : _CategoryListBody(l10n: l10n),
          ),
        ],
      ),
    );
  }
}

class _CategoryListBody extends StatelessWidget {
  const _CategoryListBody({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: TradingSymbolCategoryType.all.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        thickness: 1,
        indent: 16,
        endIndent: 16,
        color: MarketPageColors.divider,
      ),
      itemBuilder: (context, index) {
        final category = TradingSymbolCategoryType.all[index];
        return Material(
          color: Colors.white,
          child: InkWell(
            onTap: () => context.push(
              AppRoutes.marketAddSymbolsCategory(category.apiType),
            ),
            child: SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.title(l10n),
                        style: const TextStyle(
                          fontSize: 16,
                          color: MarketPageColors.title,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 22,
                      color: MarketPageColors.secondaryText,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchResultsBody extends ConsumerWidget {
  const _SearchResultsBody({
    required this.query,
    required this.addingIds,
    required this.onAddSymbol,
    required this.onOpenDetail,
  });

  final String query;
  final Set<int> addingIds;
  final Future<void> Function(TradingSymbolCandidate) onAddSymbol;
  final void Function(TradingSymbolCandidate) onOpenDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final resultsAsync = ref.watch(filteredTradingSymbolFuzzySearchProvider);

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$e', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                ref.invalidate(tradingSymbolFuzzySearchProvider(query));
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

        final sections =
            TradingSymbolCategoryType.groupCandidates(catalog);
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            for (var s = 0; s < sections.length; s++) ...[
              MarketSectionHeader(
                title: sections[s].category.title(l10n),
              ),
              for (var i = 0; i < sections[s].items.length; i++) ...[
                AddTradingSymbolCatalogRow(
                  candidate: sections[s].items[i],
                  adding: addingIds.contains(sections[s].items[i].varietyId),
                  onAddTap: () => onAddSymbol(sections[s].items[i]),
                  onRowTap: () => onOpenDetail(sections[s].items[i]),
                ),
                if (i < sections[s].items.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: MarketPageColors.divider,
                  ),
              ],
            ],
          ],
        );
      },
    );
  }
}
