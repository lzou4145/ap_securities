import 'package:ap_securities/features/chart/domain/chart_candle.dart';

/// MQTT history response tagged with the requested symbol.
class MqttHistoryResult {
  const MqttHistoryResult({
    required this.symbol,
    required this.bars,
  });

  final String symbol;
  final List<ChartCandle> bars;
}
