import 'package:ap_securities/features/personalized_trading/presentation/widgets/rank_list_row.dart';
import 'package:intl/intl.dart';

abstract final class FollowDetailsFormat {
  static String displayName(String accountName, int accountId) {
    final name = accountName.trim();
    if (name.isNotEmpty) return name;
    return '#$accountId';
  }

  static String formatTime(String raw, String locale) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '--';
    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      return DateFormat('yyyy-MM-dd HH:mm', locale).format(parsed.toLocal());
    }
    return trimmed;
  }

  static String formatBalance(String raw) => RankListRow.formatBalance(raw);

  static String formatCommission(int rate) =>
      rate > 0 ? '$rate%' : '--';
}
