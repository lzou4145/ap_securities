import 'package:ap_securities/features/portfolio/domain/holding_row.dart';

class PortfolioRepository {
  Future<List<HoldingRow>> fetchHoldings() async {
    await Future<void>.delayed(const Duration(milliseconds: 480));
    return const [
      HoldingRow(
        name: '亚太证券模拟',
        code: 'APX',
        quantity: 400,
        marketValue: 5152,
        pnlPercent: 0.052,
      ),
      HoldingRow(
        name: '沪深300 ETF',
        code: '510300',
        quantity: 1200,
        marketValue: 4820.4,
        pnlPercent: -0.011,
      ),
    ];
  }
}
