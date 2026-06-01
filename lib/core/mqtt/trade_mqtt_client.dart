import 'dart:async';

import 'package:ap_securities/core/mqtt/mqtt_connection_policy.dart';
import 'package:ap_securities/core/mqtt/mqtt_publish_payload_text.dart';
import 'package:ap_securities/core/mqtt/trade_mqtt_commands.dart';
import 'package:ap_securities/core/mqtt/trade_mqtt_config.dart';
import 'package:ap_securities/core/mqtt/trade_mqtt_log.dart';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

typedef TradeMqttMessageHandler = void Function(
  String topic,
  String payload,
);

typedef TradeMqttBeforeConnect = Future<void> Function(String deviceNo);

/// WebSocket MQTT client for trade commands and account push channel.
class TradeMqttClient {
  MqttServerClient? _client;
  String? _accountId;
  String? _deviceNo;
  String? _mqttAccount;
  String? _accessToken;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _pushSub;
  Timer? _healthTimer;
  Future<void>? _connecting;
  DateTime? _lastActivityAt;
  var _intentionalDisconnect = false;
  var _connectInProgress = false;

  TradeMqttMessageHandler? onMessage;

  VoidCallback? onReconnected;
  VoidCallback? onConnectionLost;

  /// Called before each MQTT connect / reconnect attempt.
  TradeMqttBeforeConnect? onBeforeConnect;

  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  String? get accountId => _accountId;

  Future<void> connect({
    required String mqttAccount,
    required String accessToken,
    required String accountId,
    required String deviceNo,
  }) async {
    if (mqttAccount.isEmpty ||
        accessToken.isEmpty ||
        accountId.isEmpty ||
        deviceNo.isEmpty) {
      tradeMqttLog(
        'connect skipped: missing credentials '
        '(mqttAccount=${mqttAccount.isEmpty}, token=${accessToken.isEmpty}, '
        'accountId=${accountId.isEmpty}, deviceNo=${deviceNo.isEmpty})',
      );
      return;
    }

    final sessionKey = '$mqttAccount:$accountId:$accessToken:$deviceNo';
    if (_sessionKey == sessionKey && isConnected) {
      _publishSessionSubscriptions();
      return;
    }

    if (_connecting != null) {
      await _connecting;
      if (_sessionKey == sessionKey && isConnected) return;
    }

    _connecting = _connectInternal(
      mqttAccount: mqttAccount,
      accessToken: accessToken,
      accountId: accountId,
      deviceNo: deviceNo,
      sessionKey: sessionKey,
    );
    try {
      await _connecting;
    } finally {
      _connecting = null;
    }
  }

  Future<void> reconnectIfNeeded() async {
    final mqttAccount = _mqttAccount;
    final accessToken = _accessToken;
    final accountId = _accountId;
    final deviceNo = _deviceNo;
    if (mqttAccount == null ||
        accessToken == null ||
        accountId == null ||
        deviceNo == null ||
        mqttAccount.isEmpty ||
        accessToken.isEmpty ||
        accountId.isEmpty ||
        deviceNo.isEmpty) {
      return;
    }

    if (isConnected) {
      _publishSessionSubscriptions();
      _touchActivity();
      return;
    }

    await connect(
      mqttAccount: mqttAccount,
      accessToken: accessToken,
      accountId: accountId,
      deviceNo: deviceNo,
    );
  }

  String? _sessionKey;

  Future<void> _connectInternal({
    required String mqttAccount,
    required String accessToken,
    required String accountId,
    required String deviceNo,
    required String sessionKey,
  }) async {
    _connectInProgress = true;
    try {
      final clientId = TradeMqttConfig.clientId(
        accountId: accountId,
        deviceNo: deviceNo,
      );
      tradeMqttLog(
        'connecting → ${TradeMqttConfig.websocketServer}:${TradeMqttConfig.port} '
        'clientId=$clientId subscribe=${TradeMqttConfig.pushTopic(accountId)}',
      );

      await disconnect(sendLogout: false);

      _sessionKey = sessionKey;
      _accountId = accountId;
      _deviceNo = deviceNo;
      _mqttAccount = mqttAccount;
      _accessToken = accessToken;
      _intentionalDisconnect = false;
      final client = MqttServerClient(TradeMqttConfig.websocketServer, clientId)
        ..port = TradeMqttConfig.port
        ..useWebSocket = true
        ..logging(on: TradeMqttConfig.loggingEnabled)
        ..keepAlivePeriod = 30
        ..connectTimeoutPeriod = 15000
        ..autoReconnect = false
        ..resubscribeOnAutoReconnect = true
        ..setProtocolV311()
        ..websocketProtocols = MqttClientConstants.protocolsSingleDefault;

      client.connectionMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .authenticateAs(mqttAccount, accessToken)
          .startClean();

      _bindConnectionCallbacks(client);
      _client = client;

      try {
        await onBeforeConnect?.call(deviceNo);
        await client.connect();
      } on Object catch (e, st) {
        tradeMqttLog('connect failed: $e');
        if (TradeMqttConfig.loggingEnabled) {
          debugPrint('$st');
        }
        await disconnect(sendLogout: false);
        return;
      }

      if (client.connectionStatus?.state != MqttConnectionState.connected) {
        tradeMqttLog('connect failed: status=${client.connectionStatus}');
        await disconnect(sendLogout: false);
      }
    } finally {
      _connectInProgress = false;
    }
  }

  void _bindConnectionCallbacks(MqttServerClient client) {
    client.onConnected = () {
      final accountId = _accountId;
      if (accountId == null) return;
      unawaited(_onSessionEstablished(accountId));
    };
    client.onDisconnected = () {
      if (_intentionalDisconnect || _connectInProgress) return;
      tradeMqttLog('disconnected (unsolicited)');
      onConnectionLost?.call();
      unawaited(_scheduleReconnect());
    };
    client.pongCallback = _touchActivity;
  }

  Future<void> _scheduleReconnect() async {
    if (_intentionalDisconnect || _connectInProgress) return;
    if (_connecting != null) {
      await _connecting;
      return;
    }
    await reconnectIfNeeded();
  }

  Future<void> _onSessionEstablished(String accountId) async {
    final client = _client;
    if (client == null || !isConnected) return;

    client.subscribe(TradeMqttConfig.pushTopic(accountId), MqttQos.atMostOnce);
    await _attachMessageListener();
    _touchActivity();
    _startHealthMonitor();
    _publishSessionSubscriptions();
    onReconnected?.call();

    tradeMqttLog(
      'connected ✓ accountId=$accountId mqttUser=$_mqttAccount '
      'subscribe=${TradeMqttConfig.pushTopic(accountId)}',
    );
  }

  Future<void> _attachMessageListener() async {
    await _pushSub?.cancel();
    final stream = _client?.updates;
    if (stream == null) return;
    _pushSub = stream.listen(_onMessages);
  }

  void _publishSessionSubscriptions() {
    final accountId = _accountId;
    if (accountId == null || !isConnected) return;

    publishCommand(TradeMqttCommands.subscribePositions(accountId));
    publishCommand(TradeMqttCommands.subscribeAmountFloating);
  }

  void _touchActivity() {
    _lastActivityAt = DateTime.now();
  }

  void _startHealthMonitor() {
    _healthTimer?.cancel();
    _healthTimer = Timer.periodic(
      MqttConnectionPolicy.healthCheckInterval,
      (_) => _runHealthCheck(),
    );
  }

  void _runHealthCheck() {
    final client = _client;
    if (client == null || _accountId == null) return;

    if (!isConnected) {
      onConnectionLost?.call();
      unawaited(_scheduleReconnect());
      return;
    }

    final last = _lastActivityAt;
    if (last == null) return;

    final silentFor = DateTime.now().difference(last);
    if (silentFor <= MqttConnectionPolicy.tradeStaleTimeout) return;

    tradeMqttLog(
      'stale ${silentFor.inSeconds}s, forcing reconnect accountId=$_accountId',
    );
    _touchActivity();
    unawaited(_scheduleReconnect());
  }

  void _onMessages(List<MqttReceivedMessage<MqttMessage>> messages) {
    _touchActivity();
    for (final message in messages) {
      final payload = message.payload;
      if (payload is! MqttPublishMessage) continue;

      final text = mqttPublishPayloadToUtf8String(payload);
      onMessage?.call(message.topic, text);
    }
  }

  void publishCommand(String command) {
    final client = _client;
    if (client == null || !isConnected || command.isEmpty) {
      tradeMqttLog(
        'publish skipped (connected=$isConnected): $command',
      );
      return;
    }

    final builder = MqttClientPayloadBuilder()..addString(command);
    client.publishMessage(
      TradeMqttConfig.tradePublishTopic,
      MqttQos.atMostOnce,
      builder.payload!,
    );
    tradeMqttLog('publish → ${TradeMqttConfig.tradePublishTopic}: $command');
  }

  Future<void> disconnect({bool sendLogout = true}) async {
    _intentionalDisconnect = true;
    _healthTimer?.cancel();
    _healthTimer = null;

    final wasConnected = isConnected;
    final account = _accountId;
    if (sendLogout && isConnected) {
      try {
        publishCommand('LOGOUT');
      } on Object {
        // Ignore publish errors during teardown.
      }
    }

    await _pushSub?.cancel();
    _pushSub = null;

    final client = _client;
    _client = null;
    _accountId = null;
    _sessionKey = null;
    _lastActivityAt = null;

    if (sendLogout) {
      _mqttAccount = null;
      _accessToken = null;
      _deviceNo = null;
    }

    if (client != null) {
      try {
        client.autoReconnect = false;
        client.disconnect();
      } on Object {
        // Ignore disconnect errors.
      }
    }

    if (wasConnected || account != null) {
      tradeMqttLog('disconnected accountId=$account logout=$sendLogout');
    }
    _intentionalDisconnect = false;
  }

  Future<void> dispose() async {
    onMessage = null;
    onReconnected = null;
    onConnectionLost = null;
    onBeforeConnect = null;
    await disconnect(sendLogout: false);
    _mqttAccount = null;
    _accessToken = null;
    _deviceNo = null;
  }
}
