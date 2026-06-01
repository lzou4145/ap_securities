import 'package:ap_securities/features/market/domain/trading_symbol_candidate.dart';
import 'package:ap_securities/l10n/l10n.dart';

/// Catalog API `type`: 1外汇 2金属 3能源 4指数 5数字货币.
enum TradingSymbolCategoryType {
  forex('1'),
  metal('2'),
  energy('3'),
  indices('4'),
  crypto('5');

  const TradingSymbolCategoryType(this.apiType);

  final String apiType;

  static const List<TradingSymbolCategoryType> all = values;

  String title(AppLocalizations l10n) => switch (this) {
        forex => l10n.marketSymbolCategoryForex,
        metal => l10n.marketSymbolCategoryMetal,
        energy => l10n.marketSymbolCategoryEnergy,
        indices => l10n.marketSymbolCategoryIndex,
        crypto => l10n.marketSymbolCategoryCrypto,
      };

  static TradingSymbolCategoryType? fromApiType(String type) {
    for (final category in all) {
      if (category.apiType == type) return category;
    }
    return null;
  }

  static TradingSymbolCategoryType? fromVarietyType(int type) =>
      fromApiType(type.toString());

  /// Groups [candidates] by [Variety.type] in catalog display order (1–5).
  static List<TradingSymbolCategorySection> groupCandidates(
    List<TradingSymbolCandidate> candidates,
  ) {
    final sections = <TradingSymbolCategorySection>[];
    for (final category in all) {
      final typeId = int.parse(category.apiType);
      final items = candidates
          .where((c) => c.variety.type == typeId)
          .toList(growable: false);
      if (items.isNotEmpty) {
        sections.add(
          TradingSymbolCategorySection(category: category, items: items),
        );
      }
    }
    return sections;
  }
}

class TradingSymbolCategorySection {
  const TradingSymbolCategorySection({
    required this.category,
    required this.items,
  });

  final TradingSymbolCategoryType category;
  final List<TradingSymbolCandidate> items;
}
