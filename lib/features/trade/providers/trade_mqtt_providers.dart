import 'dart:async';

import 'package:ap_securities/core/mqtt/position_floating_parser.dart';
import 'package:ap_securities/core/mqtt/user_floating_parser.dart';
import 'package:ap_securities/core/mqtt/market_mqtt_providers.dart';
import 'package:ap_securities/core/mqtt/trade_mqtt_client.dart';
import 'package:ap_securities/core/mqtt/trade_mqtt_log.dart';
import 'package:ap_securities/core/mqtt/trade_mqtt_response.dart';
import 'package:ap_securities/features/trade/providers/trade_mqtt_response_providers.dart';
import 'package:ap_securities/features/trade/providers/pend_order_providers.dart';
import 'package:ap_securities/features/trade/providers/trade_tab_providers.dart';
import 'package:ap_securities/features/account/providers/account_providers.dart';
import 'package:ap_securities/features/auth/providers/auth_repository_provider.dart';
import 'package:ap_securities/providers/active_account_scope.dart';
import 'package:ap_securities/providers/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tradeMqttClientProvider = Provider<TradeMqttClient>((ref) {
  final client = TradeMqttClient();
  client.onBeforeConnect = (_) async {
    await ref.read(authRepositoryProvider).initMqttKey();
  };
  ref.onDispose(client.dispose);
  return client;
});

/// Keeps trade MQTT in sync with login / account switch / sign-out. Watch from [App].
final tradeMqttLifecycleProvider = Provider<void>((ref) {
  final mqtt = ref.read(tradeMqttClientProvider);
  var syncGeneration = 0;
  var responseSequence = 0;

  mqtt.onMessage = (topic, payload) {
    tradeMqttLog('← $topic: $payload');

    final userFloating = UserFloatingParser.tryParsePayload(payload);
    if (userFloating != null) {
      ref.read(tradeTabProvider.notifier).applyUserFloating(userFloating);
      tradeMqttLog(
        'user floating balance=${userFloating.balance} '
        'account=${userFloating.accountId}',
      );
      return;
    }

    final positionUpdate = PositionFloatingParser.tryParsePayload(payload);
    if (positionUpdate != null) {
      ref.read(tradeTabProvider.notifier).applyPositionFloating(positionUpdate);
      tradeMqttLog(
        'position floating ${positionUpdate.orderId} '
        '${positionUpdate.symbol} pnl=${positionUpdate.floatingPnl} '
        'margin=${positionUpdate.margin}',
      );
      return;
    }

    final parsed = TradeMqttResponseParser.parse(payload);
    if (parsed == null) {
      tradeMqttLog('parse skipped (not trade response / floating)');
      return;
    }
    ref.read(tradeMqttLastResponseProvider.notifier).state =
        TradeMqttResponseEvent(
      response: parsed,
      sequence: ++responseSequence,
    );
    tradeMqttLog(
      'parsed ${parsed.operationType.wireValue} '
      'code=${parsed.statusCode} success=${parsed.isSuccess} '
      'msg=${parsed.message}',
    );

    if (parsed.isSuccess &&
        parsed.operationType == TradeMqttOperationType.orderBack) {
      ref.invalidate(pendOrderListProvider);
    }
  };

  Future<void> syncTradeMqtt() async {
    final generation = ++syncGeneration;
    final auth = ref.read(authStateProvider);
    final active = ref.read(accountSessionProvider).valueOrNull?.activeAccount;

    if (auth is! AuthStateSignedIn) {
      tradeMqttLog('sync: not signed in → disconnect');
      await mqtt.disconnect();
      return;
    }

    if (active == null) {
      tradeMqttLog('sync: no active account → disconnect');
      await mqtt.disconnect();
      return;
    }

    if (active.mqttAccount.isEmpty || active.accessToken.isEmpty) {
      tradeMqttLog(
        'sync: missing mqtt credentials '
        'accountId=${active.accountId} mqttAccount=${active.mqttAccount.isEmpty} '
        'token=${active.accessToken.isEmpty} → disconnect',
      );
      await mqtt.disconnect();
      return;
    }

    final deviceNo = await ref.read(deviceNoProvider.future);
    if (deviceNo.isEmpty) {
      tradeMqttLog('sync: empty deviceNo → disconnect');
      await mqtt.disconnect();
      return;
    }

    tradeMqttLog(
      'sync: connecting accountId=${active.accountId} '
      'mqttAccount=${active.mqttAccount} deviceNo=$deviceNo',
    );

    await mqtt.connect(
      mqttAccount: active.mqttAccount,
      accessToken: active.accessToken,
      accountId: active.accountId,
      deviceNo: deviceNo,
    );
    if (generation != syncGeneration) {
      tradeMqttLog('sync: stale generation, ignored');
      return;
    }

    tradeMqttLog(
      'sync: done connected=${mqtt.isConnected} accountId=${mqtt.accountId}',
    );
  }

  ref.listen(activeAccountScopeProvider, (previous, next) {
    if (previous == next) return;
    unawaited(syncTradeMqtt());
  });

  ref.listen(accountSessionProvider, (previous, next) {
    final prevActive = previous?.valueOrNull?.activeAccount;
    final nextActive = next.valueOrNull?.activeAccount;
    if (prevActive?.id == nextActive?.id &&
        prevActive?.accessToken == nextActive?.accessToken &&
        prevActive?.mqttAccount == nextActive?.mqttAccount) {
      return;
    }
    unawaited(syncTradeMqtt());
  });

  unawaited(syncTradeMqtt());
});
