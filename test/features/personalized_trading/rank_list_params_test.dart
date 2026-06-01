import 'package:ap_securities/features/personalized_trading/domain/rank_list_params.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RankListParams maps UI keys to API query values', () {
    expect(RankListParams.timeType('7d'), '1');
    expect(RankListParams.timeType('15d'), '2');
    expect(RankListParams.timeType('30d'), '3');

    expect(RankListParams.rankType('top20'), '1');
    expect(RankListParams.rankType('bottom20'), '2');
  });
}
