/// Central paths for raster icons under `assets/app_icons`.
///
/// **Multi-resolution layout** (Flutter convention):
/// - `assets/app_icons/<name>.png` — 1× bitmap (baseline density)
/// - `assets/app_icons/2.0x/<name>.png` — 2×
/// - `assets/app_icons/3.0x/<name>.png` — 3×
///
/// Logical size in UI stays the same; Flutter picks the closest file for the
/// device pixel ratio. Replace the generated `logo` triple with your brand
/// artwork, then add more names here (one basename → three files each).
abstract final class AppIcons {
  static const String _root = 'assets/app_icons';

  /// Brand mark (placeholder — replace PNGs, keep the same basename).
  static const String logo = '$_root/logo.png';

  /// Login hero background (upper screen).
  static const String authBg = '$_root/auth_bg.png';

  /// Bottom navigation — normal / selected (paired `_sel` assets).
  static const String icTabMarket = '$_root/ic_tab_market.png';
  static const String icTabMarketSel = '$_root/ic_tab_market_sel.png';
  static const String icTabChart = '$_root/ic_tab_chart.png';
  static const String icTabChartSel = '$_root/ic_tab_chart_sel.png';
  static const String icTabTrade = '$_root/ic_tab_trade.png';
  static const String icTabTradeSel = '$_root/ic_tab_trade_sel.png';
  static const String icTabHistory = '$_root/ic_tab_history.png';
  static const String icTabHistorySel = '$_root/ic_tab_history_sel.png';
  static const String icTabSettings = '$_root/ic_tab_settings.png';
  static const String icTabSettingsSel = '$_root/ic_tab_settings_sel.png';

  static const String icAdd = '$_root/ic_add.png';
  static const String icMove = '$_root/ic_move.png';
  static const String icSelect = '$_root/ic_select.png';
  static const String icEdit = '$_root/ic_edit.png';
  static const String icDelete = '$_root/ic_delete.png';

  /// Chart tab app bar — trade order / quick trade toggle.
  static const String icTime = '$_root/ic_time.png';
  static const String icLink = '$_root/ic_link.png';

  /// Chart tab title bar — series type / indicators menus (PNG fallbacks).
  static const String icChartSeriesType = '$_root/ic_chart_series_type.png';
  static const String icChartIndicators = '$_root/ic_chart_indicators.png';
  static const String icChartFit = '$_root/ic_chart_fit.png';
  static const String icChartRealtime = '$_root/ic_chart_realtime.png';

  /// Chart tab toolbar — SVG sources under `assets/icons/`.
  static const String _svgRoot = 'assets/icons';
  static const String svgChartToolIcon = '$_svgRoot/chart_tool_icon.svg';
  static const String svgChartToolSeriesType =
      '$_svgRoot/chart_tool_series_type_icon.svg';
  static const String svgChartToolBars = '$_svgRoot/chart_tool_bars_icon.svg';
  static const String svgChartToolHbars = '$_svgRoot/chart_tool_hbars_icon.svg';
  static const String svgChartToolIndicator =
      '$_svgRoot/chart_tool_indicator_icon.svg';
  static const String svgChartToolFit = '$_svgRoot/chart_tool_fit_icon.svg';
  static const String svgChartToolRealtime =
      '$_svgRoot/chart_tool_realtime_icon.svg';
  static const String svgChartToolLink = '$_svgRoot/chart_tool_link_icon.svg';
  static const String svgChatToolDarkIcon = '$_svgRoot/chat_tool_dark_icon.svg';
  static const String svgChatToolLightIcon =
      '$_svgRoot/chat_tool_light_icon.svg';

  /// Settings list row icons.
  static const String icSettingsPersonalizedTrading =
      '$_root/ic_settings_personalized_trading.png';
  static const String icSettingsSwitchLanguage =
      '$_root/ic_settings_switch_language.png';
  static const String icSettingsCustomerService =
      '$_root/ic_settings_customer_service.png';
  static const String icSettingsBackendLink =
      '$_root/ic_settings_backend_link.png';
  static const String icSettingsRealNameAuth =
      '$_root/ic_settings_real_name_auth.png';

  /// Build path for another triple-density asset: `my_icon.png` + `2.0x/` +
  /// `3.0x/` folders.
  static String png(String baseName) => '$_root/$baseName.png';
}
