/// Success screen content variant (place / modify SL/TP / close position).
enum TradeOrderSuccessVariant {
  place,
  modify,
  close,
}

extension TradeOrderSuccessVariantParsing on TradeOrderSuccessVariant {
  static TradeOrderSuccessVariant fromQuery(String? value) {
    return switch (value) {
      'modify' => TradeOrderSuccessVariant.modify,
      'close' => TradeOrderSuccessVariant.close,
      _ => TradeOrderSuccessVariant.place,
    };
  }

  String get queryValue => switch (this) {
        TradeOrderSuccessVariant.place => 'place',
        TradeOrderSuccessVariant.modify => 'modify',
        TradeOrderSuccessVariant.close => 'close',
      };
}
