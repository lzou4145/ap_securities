import 'package:ap_securities/core/api/models/api_models_account.dart';
import 'package:ap_securities/core/mqtt/position_floating_parser.dart';
import 'package:ap_securities/core/mqtt/user_floating_parser.dart';
import 'package:ap_securities/features/account/domain/stored_account.dart';
import 'package:ap_securities/features/account/providers/account_providers.dart';
import 'package:ap_securities/features/trade/data/trade_summary_calculator.dart';
import 'package:ap_securities/features/trade/data/trade_wallets_mapper.dart';
import 'package:ap_securities/features/trade/domain/open_position.dart';
import 'package:ap_securities/features/trade/domain/trade_account_summary.dart';
import 'package:ap_securities/features/trade/domain/trade_page_data.dart';
import 'package:ap_securities/providers/active_account_scope.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Live trade tab: wallets from login, positions from MQTT floating updates.
final tradeTabProvider =
    NotifierProvider<TradeTabNotifier, TradeTabState>(TradeTabNotifier.new);

class TradeTabState {
  const TradeTabState({
    required this.baseBalance,
    required this.positionsByOrderId,
  });

  /// 结余 — from [WalletsTrade.amount] / [UserFloatingUpdate.balance].
  final double baseBalance;
  final Map<String, OpenPosition> positionsByOrderId;

  double get totalFloatingPnl => positionsByOrderId.values.fold<double>(
        0,
        (sum, p) => sum + p.profit,
      );

  TradeAccountSummary get summary => TradeSummaryCalculator.liveSummary(
        balance: baseBalance,
        positions: positionsByOrderId.values,
      );

  List<OpenPosition> get positions {
    final list = positionsByOrderId.values.toList();
    list.sort((a, b) => b.id.compareTo(a.id));
    return list;
  }

  TradePageData toPageData() {
    final all = positions;
    return TradePageData(
      totalProfitUsd: totalFloatingPnl,
      summary: summary,
      positions: [
        for (final p in all)
          if (!p.isFollowPosition) p,
      ],
      followPositions: [
        for (final p in all)
          if (p.isFollowPosition) p,
      ],
    );
  }

  TradeTabState copyWith({
    double? baseBalance,
    Map<String, OpenPosition>? positionsByOrderId,
  }) {
    return TradeTabState(
      baseBalance: baseBalance ?? this.baseBalance,
      positionsByOrderId: positionsByOrderId ?? this.positionsByOrderId,
    );
  }
}

class TradeTabNotifier extends Notifier<TradeTabState> {
  @override
  TradeTabState build() {
    ref.watch(activeAccountScopeProvider);
    ref.listen(accountSessionProvider, (previous, next) {
      final prevActive = previous?.valueOrNull?.activeAccount;
      final nextActive = next.valueOrNull?.activeAccount;
      if (prevActive?.id != nextActive?.id) {
        _resetForAccount(nextActive);
        return;
      }
      if (prevActive?.walletsTrade != nextActive?.walletsTrade) {
        refreshSummaryFromActiveAccount();
      }
    });
    final active = ref.read(accountSessionProvider).valueOrNull?.activeAccount;
    return _stateForAccount(active);
  }

  void _resetForAccount(StoredAccount? account) {
    state = _stateForAccount(account);
  }

  TradeTabState _stateForAccount(StoredAccount? account) {
    final wallets = account?.walletsTrade;
    final baseBalance = wallets != null
        ? TradeWalletsMapper.parseBalance(wallets)
        : 0.0;
    return TradeTabState(
      baseBalance: baseBalance,
      positionsByOrderId: const {},
    );
  }

  void applyPositionFloating(PositionFloatingUpdate update) {
    final active = ref.read(accountSessionProvider).valueOrNull?.activeAccount;
    if (active == null) return;
    if (!_wireAccountMatchesActive(update.accountId, active)) return;

    final nextPositions = Map<String, OpenPosition>.from(state.positionsByOrderId)
      ..[update.orderId] = update.toOpenPosition();
    state = state.copyWith(positionsByOrderId: nextPositions);
  }

  void applyUserFloating(UserFloatingUpdate update) {
    final active = ref.read(accountSessionProvider).valueOrNull?.activeAccount;
    if (active == null) return;
    if (!_wireAccountMatchesActive(update.accountId, active)) return;

    state = state.copyWith(baseBalance: update.balance);
  }

  void removePosition(String orderId) {
    if (!state.positionsByOrderId.containsKey(orderId)) return;
    final next = Map<String, OpenPosition>.from(state.positionsByOrderId)
      ..remove(orderId);
    state = state.copyWith(positionsByOrderId: next);
  }

  void refreshSummaryFromActiveAccount() {
    final active = ref.read(accountSessionProvider).valueOrNull?.activeAccount;
    final wallets = active?.walletsTrade;
    if (wallets == null) return;
    state = state.copyWith(
      baseBalance: TradeWalletsMapper.parseBalance(wallets),
    );
  }

  /// Updates 结余 from `getWalletsTrade`; equity/margin recompute from open positions.
  void applyWalletsSnapshot(AccountWalletsTrade snapshot) {
    state = state.copyWith(
      baseBalance: TradeWalletsMapper.parseBalanceFromSnapshot(snapshot),
    );
  }
}

/// MQTT may send API [StoredAccount.accountId] or [StoredAccount.mqttAccount].
bool _wireAccountMatchesActive(String wireAccount, StoredAccount active) {
  final wire = wireAccount.trim();
  if (wire.isEmpty) return false;
  return wire == active.accountId ||
      (active.mqttAccount.isNotEmpty && wire == active.mqttAccount);
}
