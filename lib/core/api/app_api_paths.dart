// ignore_for_file: constant_identifier_names

/// APP-api path constants (from OpenAPI export).
abstract final class AppApiPaths {
  AppApiPaths._();

  /// 获取账号资金
  static const account_getWalletsTrade = '/api/account/getWalletsTrade';

  /// 添加账号
  static const addAccountByDeviceNo = '/api/addAccountByDeviceNo';

  /// 切换账号
  static const changeAccountByDeviceNo = '/api/changeAccountByDeviceNo';

  /// 获取账号
  static const getAccountByDeviceNo = '/api/getAccountByDeviceNo';

  /// 获取登录验证码
  static const getLoginCode = '/api/getLoginCode';

  /// 重置 MQTT Key
  static const initMqttKey = '/api/initMqttKey';

  /// 登录
  static const login = '/api/login';

  /// 登出
  static const logout = '/api/logout';

  /// 添加账号合约品种
  static const market_addAccountVariety = '/api/market/addAccountVariety';

  /// 删除账号合约品种
  static const market_delAccountVariety = '/api/market/delAccountVariety';

  /// 取消跟单用户
  static const market_delFollow = '/api/market/delFollow';

  /// 获取账号合约品种列表
  static const market_getAccountVarietyList =
      '/api/market/getAccountVarietyList';

  /// 获取默认合约品种列表
  static const market_getDefAccountVarietyList =
      '/api/market/getDefAccountVarietyList';

  /// 获取跟单用户列表
  static const market_getFollowList = '/api/market/getFollowList';

  /// 获取用户排名列表
  static const market_getRankList = '/api/market/getRankList';

  /// 获取带单用户配置
  static const market_getSingleConfig = '/api/market/getSingleConfig';

  /// 获取带单用户列表
  static const market_getSingleList = '/api/market/getSingleList';

  /// 获取倍数选项
  static const market_multipleNumOptions = '/api/market/multipleNumOptions';

  /// 设置账号合约品种排序
  static const market_setAccountVarietySort =
      '/api/market/setAccountVarietySort';

  /// 设置跟单用户
  static const market_setFollow = '/api/market/setFollow';

  /// 设置带单用户配置
  static const market_setSingleConfig = '/api/market/setSingleConfig';

  /// 合约品种列表
  static const market_varietyList = '/api/market/varietyList';

  /// 按名称模糊查询合约品种
  static const market_varietyFuzzy = '/api/market/varietyFuzzy';

  /// 资金流水记录列表
  static const order_fundFlowRecords = '/api/order/fundFlowRecords';

  /// 订单记录列表
  static const order_historyList = '/api/order/historyList';

  /// 订单记录统计
  static const order_historyTotal = '/api/order/historyTotal';

  /// 委托订单列表
  static const order_pendOrderList = '/api/order/pendOrderList';

  /// 按订单号查询订单详情
  static const order_getOrderInfoByOrderId =
      '/api/order/getOrderInfoByOrderId';

  /// 注册
  static const reg = '/api/reg';

  /// 发送验证码
  static const sendCode = '/api/sendCode';

  /// 获取通知详情
  static const service_getNoticeContent = '/api/service/getNoticeContent';

  /// 获取通知列表
  static const service_getNoticeList = '/api/service/getNoticeList';
}
