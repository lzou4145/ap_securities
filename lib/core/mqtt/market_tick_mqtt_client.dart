import 'dart:async';

import 'package:ap_securities/core/mqtt/mqtt_connection_policy.dart';
import 'package:ap_securities/core/mqtt/mqtt_day_parser.dart';
import 'package:ap_securities/core/mqtt/mqtt_history_parser.dart';
import 'package:ap_securities/core/mqtt/mqtt_tick_config.dart';
import 'package:ap_securities/core/mqtt/mqtt_tick_parser.dart';
import 'package:ap_securities/features/chart/domain/mqtt_history_result.dart';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

typedef MqttTickHandler = void Function(MqttTickQuote tick);
typedef MqttDayHighLowHandler = void Function(List<MqttDayQuote> quotes);
typedef MqttHistoryHandler = void Function(MqttHistoryResult history);

/// WebSocket MQTT client for ticks and history (one connection per device id).
class MarketTickMqttClient {
  MqttServerClient? _client;
  String? _deviceId;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _pushSub;
  Timer? _symbolDebounce;
  Timer? _dayDebounce;
  Timer? _healthTimer;
  Future<void>? _connecting;
  String? _pendingHistorySymbol;
  List<String> _cachedSymbols = [];
  DateTime? _lastActivityAt;
  var _intentionalDisconnect = false;

  void Function(MqttTickQuote tick)? onTick;
  void Function(List<MqttDayQuote> quotes)? onDayHighLow;
  void Function(MqttHistoryResult history)? onHistory;

  /// Fired after connect / auto-reconnect when subscriptions are restored.
  VoidCallback? onReconnected;

  /// Fired on unsolicited disconnect or health-check failure.
  VoidCallback? onConnectionLost;

  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  String? get deviceId => _deviceId;

  Future<void> connect({required String deviceId}) async {
    if (deviceId.isEmpty) return;

    if (_deviceId == deviceId && isConnected) {
      await _republishCachedSubscriptions();
      return;
    }

    if (_connecting != null) {
      await _connecting;
      if (_deviceId == deviceId && isConnected) return;
    }

    _connecting = _connectInternal(deviceId);
    try {
      await _connecting;
    } finally {
      _connecting = null;
    }
  }

  /// Reconnect or refresh subscriptions when network returns / connection is stale.
  Future<void> reconnectIfNeeded() async {
    final deviceId = _deviceId;
    if (deviceId == null || deviceId.isEmpty) return;

    if (isConnected) {
      await _republishCachedSubscriptions();
      _touchActivity();
      return;
    }

    await connect(deviceId: deviceId);
  }

  Future<void> _connectInternal(String deviceId) async {
    await disconnect();

    _deviceId = deviceId;
    _intentionalDisconnect = false;

    final client = MqttServerClient(MqttTickConfig.websocketServer, deviceId)
      ..port = MqttTickConfig.port
      ..useWebSocket = true
      ..logging(on: MqttTickConfig.verboseLogging && kDebugMode)
      ..keepAlivePeriod = 30
      ..connectTimeoutPeriod = 15000
      ..autoReconnect = true
      ..resubscribeOnAutoReconnect = true
      ..setProtocolV311()
      ..websocketProtocols = MqttClientConstants.protocolsSingleDefault;

    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(deviceId)
        .authenticateAs(MqttTickConfig.username, MqttTickConfig.password)
        .startClean();

    _bindConnectionCallbacks(client);
    _client = client;

    try {
      await client.connect();
    } on Object catch (e, st) {
      if (MqttTickConfig.verboseLogging) {
        debugPrint('MQTT connect failed: $e\n$st');
      }
      await disconnect();
      return;
    }

    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      if (MqttTickConfig.verboseLogging) {
        debugPrint('MQTT not connected: ${client.connectionStatus}');
      }
      await disconnect();
    }
  }

  void _bindConnectionCallbacks(MqttServerClient client) {
    client.onConnected = () {
      final deviceId = _deviceId;
      if (deviceId == null) return;
      unawaited(_onSessionEstablished(deviceId));
    };
    client.onAutoReconnected = () {
      final deviceId = _deviceId;
      if (deviceId == null) return;
      if (MqttTickConfig.verboseLogging) {
        debugPrint('MQTT market auto-reconnected deviceId=$deviceId');
      }
      unawaited(_onSessionEstablished(deviceId));
    };
    client.onDisconnected = () {
      if (_intentionalDisconnect) return;
      if (MqttTickConfig.verboseLogging) {
        debugPrint('MQTT market disconnected (unsolicited)');
      }
      onConnectionLost?.call();
    };
    client.pongCallback = _touchActivity;
  }

  Future<void> _onSessionEstablished(String deviceId) async {
    final client = _client;
    if (client == null || !isConnected) return;

    _subscribeBrokerTopics(deviceId);
    await _attachMessageListener();
    _touchActivity();
    _startHealthMonitor();
    await _republishCachedSubscriptions();
    onReconnected?.call();
  }

  void _subscribeBrokerTopics(String deviceId) {
    final client = _client;
    if (client == null) return;

    client.subscribe(MqttTickConfig.pushTopic(deviceId), MqttQos.atMostOnce);
    client.subscribe(
      MqttTickConfig.dayPushTopic(deviceId),
      MqttQos.atMostOnce,
    );
    client.subscribe(
      MqttTickConfig.pushHistoryTopic(deviceId),
      MqttQos.atMostOnce,
    );
  }

  Future<void> _attachMessageListener() async {
    await _pushSub?.cancel();
    final stream = _client?.updates;
    if (stream == null) return;
    _pushSub = stream.listen(_onMessages);
  }

  Future<void> _republishCachedSubscriptions() async {
    if (_cachedSymbols.isEmpty) return;
    await _publishSymbolListNow(_cachedSymbols);
    await _publishDaySymbolListNow(_cachedSymbols);
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
    final deviceId = _deviceId;
    if (client == null || deviceId == null) return;

    if (!isConnected) {
      onConnectionLost?.call();
      return;
    }

    final last = _lastActivityAt;
    if (last == null) return;

    final silentFor = DateTime.now().difference(last);
    if (silentFor <= MqttConnectionPolicy.marketStaleTimeout) return;

    if (MqttTickConfig.verboseLogging) {
      debugPrint(
        'MQTT market stale ${silentFor.inSeconds}s, forcing reconnect',
      );
    }
    _touchActivity();
    client.doAutoReconnect(force: true);
  }

  void _onMessages(List<MqttReceivedMessage<MqttMessage>> messages) {
    _touchActivity();
    for (final message in messages) {
      final topic = message.topic;
      final deviceId = _deviceId;
      if (deviceId == null) continue;

      final payload = message.payload;
      if (payload is! MqttPublishMessage) continue;

      final text = MqttPublishPayload.bytesToStringAsString(
        payload.payload.message,
      );

      if (topic == MqttTickConfig.pushTopic(deviceId)) {
        final tick = MqttTickParser.parsePushPayload(text);
        if (tick != null) {
          onTick?.call(tick);
        }
        continue;
      }

      if (topic == MqttTickConfig.dayPushTopic(deviceId)) {
        final quotes = MqttDayParser.parseDayPushPayload(text);
        if (quotes.isNotEmpty) {
          onDayHighLow?.call(quotes);
        }
        continue;
      }

      if (topic == MqttTickConfig.pushHistoryTopic(deviceId)) {
        final symbol = _pendingHistorySymbol;
        final history = MqttHistoryParser.parsePushPayload(text);
        if (symbol != null && history != null) {
          onHistory?.call(
            MqttHistoryResult(symbol: symbol, bars: history.bars),
          );
        }
      }
    }
  }

  void publishSymbolList(List<String> symbols) {
    _cachedSymbols = List<String>.from(symbols);
    _symbolDebounce?.cancel();
    _symbolDebounce = Timer(const Duration(milliseconds: 250), () {
      unawaited(_publishSymbolListNow(_cachedSymbols));
    });
    publishDaySymbolList(symbols);
  }

  void publishDaySymbolList(List<String> symbols) {
    _cachedSymbols = List<String>.from(symbols);
    _dayDebounce?.cancel();
    _dayDebounce = Timer(const Duration(milliseconds: 250), () {
      unawaited(_publishDaySymbolListNow(_cachedSymbols));
    });
  }

  Future<void> _publishSymbolListNow(List<String> symbols) async {
    final client = _client;
    final deviceId = _deviceId;
    if (client == null || deviceId == null || !isConnected) return;

    final payload = MqttTickParser.buildSubscribePayload(symbols);
    if (payload.isEmpty) return;

    final topic = MqttTickConfig.subscribeTopic(deviceId);
    final builder = MqttClientPayloadBuilder()..addString(payload);
    client.publishMessage(
      topic,
      MqttQos.atMostOnce,
      builder.payload!,
    );
  }

  Future<void> _publishDaySymbolListNow(List<String> symbols) async {
    final client = _client;
    final deviceId = _deviceId;
    if (client == null || deviceId == null || !isConnected) return;

    final payload = MqttTickParser.buildSubscribePayload(symbols);
    if (payload.isEmpty) return;

    final topic = MqttTickConfig.daySubscribeTopic(deviceId);
    final builder = MqttClientPayloadBuilder()..addString(payload);
    client.publishMessage(
      topic,
      MqttQos.atMostOnce,
      builder.payload!,
    );
  }

  void requestHistory({
    required String symbol,
    required String resolution,
    required int fromMs,
    required int toMs,
  }) {
    final client = _client;
    final deviceId = _deviceId;
    if (client == null || deviceId == null || !isConnected) return;
    if (symbol.isEmpty) return;

    _pendingHistorySymbol = symbol;

    final payload = MqttHistoryParser.buildRequest(
      symbol: symbol,
      resolution: resolution,
      fromMs: fromMs,
      toMs: toMs,
    );
    final topic = MqttTickConfig.historyTopic(deviceId);
    final builder = MqttClientPayloadBuilder()..addString(payload);
    client.publishMessage(
      topic,
      MqttQos.atMostOnce,
      builder.payload!,
    );
  }

  Future<void> disconnect() async {
    _intentionalDisconnect = true;
    _healthTimer?.cancel();
    _healthTimer = null;
    _symbolDebounce?.cancel();
    _symbolDebounce = null;
    _dayDebounce?.cancel();
    _dayDebounce = null;
    await _pushSub?.cancel();
    _pushSub = null;

    final client = _client;
    _client = null;
    _deviceId = null;
    _lastActivityAt = null;

    if (client != null) {
      try {
        client.autoReconnect = false;
        client.disconnect();
      } on Object {
        // Ignore disconnect errors.
      }
    }
    _intentionalDisconnect = false;
  }

  Future<void> dispose() async {
    onTick = null;
    onDayHighLow = null;
    onHistory = null;
    onReconnected = null;
    onConnectionLost = null;
    await disconnect();
  }
}
