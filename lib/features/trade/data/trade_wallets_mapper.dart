import 'package:ap_securities/core/api/models/api_models_account.dart';
import 'package:ap_securities/core/api/models/api_models_auth.dart';

abstract final class TradeWalletsMapper {
  static double parseBalance(WalletsTrade wallets) => parseAmount(wallets.amount);

  static double parseAmount(String raw) => double.tryParse(raw.trim()) ?? 0;

  static double parseBalanceFromSnapshot(AccountWalletsTrade wallets) =>
      parseAmount(wallets.amount);

  static double parseClosePosition(AccountWalletsTrade wallets) =>
      parseAmount(wallets.closePosition);
}
