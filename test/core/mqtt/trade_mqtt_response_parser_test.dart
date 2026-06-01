import 'package:ap_securities/core/mqtt/trade_mqtt_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('extracts order id from numeric success message', () {
    expect(
      TradeMqttResponseParser.extractOrderId('20260506142349080'),
      '20260506142349080',
    );
    final response =
        TradeMqttResponseParser.parse('TRADE_BACK|0:20260506142349080');
    expect(response?.orderId, '20260506142349080');
  });

  test('parses TRADE_BACK success', () {
    final response = TradeMqttResponseParser.parse('TRADE_BACK|0:下单成功');

    expect(response, isNotNull);
    expect(response!.operationType, TradeMqttOperationType.tradeBack);
    expect(response.statusCode, 0);
    expect(response.isSuccess, isTrue);
    expect(response.message, '下单成功');
    expect(response!.orderId, isNull);
  });

  test('parses TRADE_BACK with double colon before message', () {
    final response =
        TradeMqttResponseParser.parse('TRADE_BACK|1002::可用余额不足');

    expect(response?.statusCode, 1002);
    expect(response?.isSuccess, isFalse);
    expect(response?.message, '可用余额不足');
  });

  test('parses ORDER_BACK failure with colon in message', () {
    final response =
        TradeMqttResponseParser.parse('ORDER_BACK|1001:余额不足:请充值');

    expect(response?.operationType, TradeMqttOperationType.orderBack);
    expect(response?.statusCode, 1001);
    expect(response?.isSuccess, isFalse);
    expect(response?.message, '余额不足:请充值');
  });
}
