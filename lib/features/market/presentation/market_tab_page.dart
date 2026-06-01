import 'package:ap_securities/core/assets/app_icons.dart';
import 'package:ap_securities/core/ui/app_toast.dart';
import 'package:ap_securities/core/network/api_exception.dart';
import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/features/market/presentation/widgets/market_edit_row.dart';
import 'package:ap_securities/features/market/presentation/widgets/market_empty_state.dart';
import 'package:ap_securities/features/market/presentation/widgets/market_page_colors.dart';
import 'package:ap_securities/features/market/presentation/widgets/market_quote_row.dart';
import 'package:ap_securities/features/market/presentation/widgets/market_symbol_action_sheet.dart';
import 'package:ap_securities/features/market/providers/market_watchlist_notifier.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MarketTabPage extends ConsumerStatefulWidget {
  const MarketTabPage({super.key});

  @override
  ConsumerState<MarketTabPage> createState() => _MarketTabPageState();
}

class _MarketTabPageState extends ConsumerState<MarketTabPage> {
  bool _isEditing = false;
  final _selectedIds = <String>{};

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _selectedIds.clear();
      }
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _deleteSelected() async {
    final ids = Set<String>.from(_selectedIds);
    try {
      await ref.read(marketWatchlistProvider.notifier).removeByIds(ids);
      if (mounted) setState(_selectedIds.clear);
    } on ApiException catch (e) {
      if (!mounted) return;
      context.showAppMessage(
        e.message,
        variant: AppMessageVariant.error,
      );
    }
  }

  void _openAddSymbols() {
    context.push(AppRoutes.marketAddSymbols);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final watchlistAsync = ref.watch(marketWatchlistProvider);
    final quotes = watchlistAsync.valueOrNull ?? const [];
    final isEmpty = watchlistAsync.hasValue && quotes.isEmpty;
    final hasSelection = _selectedIds.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: MarketPageColors.title,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        leading: isEmpty
            ? null
            : IconButton(
                onPressed: _toggleEditMode,
                icon: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    MarketPageColors.primaryBlue,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    AppIcons.icEdit,
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                ),
                tooltip: l10n.marketAddSymbolEditAction,
              ),
        title: Text(
          l10n.tabMarketTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: MarketPageColors.title,
          ),
        ),
        actions: [
          if (_isEditing && hasSelection)
            TextButton(
              onPressed: _deleteSelected,
              style: TextButton.styleFrom(
                foregroundColor: MarketPageColors.priceDown,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      MarketPageColors.priceDown,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      AppIcons.icDelete,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.marketDeleteAction,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else if (!_isEditing && !isEmpty)
            IconButton(
              onPressed: _openAddSymbols,
              icon: Image.asset(
                AppIcons.icAdd,
                width: 24,
                height: 24,
              ),
              tooltip: l10n.marketAddSymbolAction,
            ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: MarketPageColors.divider,
          ),
        ),
      ),
      body: watchlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$e', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(marketWatchlistProvider),
                child: Text(l10n.retryButton),
              ),
            ],
          ),
        ),
        data: (quotes) {
          if (quotes.isEmpty) {
            return MarketEmptyState(onAddTap: _openAddSymbols);
          }

          if (_isEditing) {
            return ReorderableListView.builder(
              padding: EdgeInsets.zero,
              buildDefaultDragHandles: false,
              itemCount: quotes.length,
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(marketWatchlistProvider.notifier)
                    .reorder(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final quote = quotes[index];
                return KeyedSubtree(
                  key: ValueKey(quote.id),
                  child: MarketEditRow(
                    quote: quote,
                    index: index,
                    isSelected: _selectedIds.contains(quote.id),
                    showDivider: index < quotes.length - 1,
                    onToggleSelected: () => _toggleSelection(quote.id),
                  ),
                );
              },
            );
          }

          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: quotes.length,
            separatorBuilder: (_, __) => const SizedBox.shrink(),
            itemBuilder: (context, index) {
              final quote = quotes[index];
              return MarketQuoteRow(
                quote: quote,
                showDivider: index < quotes.length - 1,
                onTap: () => showMarketSymbolActionSheet(
                  context,
                  ref,
                  quote: quote,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
