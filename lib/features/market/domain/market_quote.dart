import 'package:ap_securities/core/api/models/api_models_market.dart';

/// A watchlist row with live quote fields (mock or API-backed).
class MarketQuote {
  const MarketQuote({
    required this.id,
    required this.symbol,
    required this.variety,
    required this.updatedAt,
    required this.decimalPlace,
    required this.spread,
    required this.bid,
    required this.ask,
    this.bidDisplay,
    this.askDisplay,
    required this.bidLow,
    required this.askHigh,
    required this.trend,
  });

  final String id;
  final String symbol;
  final Variety variety;
  final String updatedAt;

  /// Price decimal places from variety (`decimal_place`).
  final int decimalPlace;
  final int spread;
  final double bid;
  final double ask;

  /// MQTT/API price text; shown verbatim when set.
  final String? bidDisplay;
  final String? askDisplay;
  /// Session low — updated from MQTT `push/day`.
  final double bidLow;

  /// Session high — updated from MQTT `push/day`.
  final double askHigh;
  final QuoteTrend trend;

  MarketQuote copyWith({
    String? id,
    String? symbol,
    Variety? variety,
    String? updatedAt,
    int? decimalPlace,
    int? spread,
    double? bid,
    double? ask,
    String? bidDisplay,
    String? askDisplay,
    double? bidLow,
    double? askHigh,
    QuoteTrend? trend,
  }) {
    return MarketQuote(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      variety: variety ?? this.variety,
      updatedAt: updatedAt ?? this.updatedAt,
      decimalPlace: decimalPlace ?? this.decimalPlace,
      spread: spread ?? this.spread,
      bid: bid ?? this.bid,
      ask: ask ?? this.ask,
      bidDisplay: bidDisplay ?? this.bidDisplay,
      askDisplay: askDisplay ?? this.askDisplay,
      bidLow: bidLow ?? this.bidLow,
      askHigh: askHigh ?? this.askHigh,
      trend: trend ?? this.trend,
    );
  }
}

enum QuoteTrend {
  up,
  down,
}
