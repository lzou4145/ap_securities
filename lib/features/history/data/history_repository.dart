import 'package:ap_securities/core/api/app_api.dart';
import 'package:ap_securities/core/api/models/api_models_order.dart';
import 'package:ap_securities/features/history/data/history_mapper.dart';
import 'package:ap_securities/features/history/data/history_period_query.dart';
import 'package:ap_securities/features/history/domain/history_period.dart';
import 'package:ap_securities/features/history/domain/trade_history_record.dart';

class HistoryRepository {
  HistoryRepository(this._api);

  final AppApi _api;

  Future<HistoryPageData> fetchHistory(
    HistoryPeriod period, {
    HistoryCustomRange? customRange,
  }) async {
    final query = HistoryPeriodQuery.forPeriod(
      period,
      customRange: customRange,
    );

    final results = await Future.wait([
      _fetchAllHistoryItems(
        type: query.type,
        startTime: query.startTime,
        endTime: query.endTime,
      ),
      _api.order.getHistoryTotal(
        query.type,
        query.startTime,
        query.endTime,
      ),
    ]);

    final items = results[0] as List<OrderHistoryItem>;
    final total = results[1] as OrderHistoryTotal;

    return HistoryPageData(
      period: period,
      records: items.map(HistoryMapper.fromApi).toList(),
      summary: HistoryMapper.summaryFromTotal(total),
    );
  }

  static const _pageSize = '50';

  Future<List<OrderHistoryItem>> _fetchAllHistoryItems({
    required String type,
    required String? startTime,
    required String? endTime,
  }) async {
    final all = <OrderHistoryItem>[];
    var page = 1;
    while (true) {
      final response = await _api.order.getHistoryList(
        type,
        startTime,
        endTime,
        '$page',
        _pageSize,
      );
      all.addAll(response.items);
      if (page >= response.lastPage || response.items.isEmpty) {
        break;
      }
      page++;
    }
    return all;
  }
}
