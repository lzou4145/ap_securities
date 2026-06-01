/// Maps UI filter keys to `GET /api/market/getRankList` query values.
abstract final class RankListParams {
  /// `time_type` — required. API: 1=7天, 2=15天, 3=30天.
  static String timeType(String uiKey) => switch (uiKey) {
        '15d' => '2',
        '30d' => '3',
        _ => '1',
      };

  /// `rank_type` — required. API: 1=前20, 2=后20.
  static String rankType(String uiKey) => switch (uiKey) {
        'bottom20' => '2',
        _ => '1',
      };
}
