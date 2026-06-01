import 'package:ap_securities/core/api/models/api_models_follow.dart';

class LeaderboardRankPageData {
  const LeaderboardRankPageData({
    required this.updatedAt,
    required this.ranks,
  });

  final DateTime updatedAt;
  final List<RankItem> ranks;
}
