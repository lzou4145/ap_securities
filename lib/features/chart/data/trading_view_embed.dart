import 'dart:convert';

/// HTML document that loads TradingView **Advanced Chart** (official embed).
///
/// Docs: https://www.tradingview.com/widget-docs/widgets/charts/advanced-chart/
abstract final class TradingViewEmbed {
  // ignore: prefer_const_constructors — JsonEncoder.withIndent is not const.
  static final JsonEncoder _prettyJson = JsonEncoder.withIndent('  ');

  /// The `symbol` argument uses TradingView notation, e.g. `SSE:000001`.
  ///
  /// [style] widget chart type: `0` bars, `1` candles, `2` line, `3` area.
  static String advancedChartHtml({
    String symbol = 'SSE:000001',
    String theme = 'light',
    String locale = 'zh_CN',
    String interval = 'D',
    String style = '1',
    bool hideSideToolbar = false,
    bool hideTopToolbar = false,
    bool hideLegend = false,
    bool hideVolume = false,
    bool withDateRanges = true,
    bool saveImage = true,
  }) {
    final config = <String, dynamic>{
      'allow_symbol_change': false,
      'calendar': false,
      'details': false,
      'hide_side_toolbar': hideSideToolbar,
      'hide_top_toolbar': hideTopToolbar,
      'hide_legend': hideLegend,
      'hide_volume': hideVolume,
      'hotlist': false,
      'interval': interval,
      'locale': locale,
      'save_image': saveImage,
      'style': style,
      'symbol': symbol,
      'theme': theme,
      'timezone': 'Asia/Shanghai',
      'autosize': true,
      'withdateranges': withDateRanges,
      'studies': <String>[],
      'support_host': 'https://www.tradingview.com',
    };
    final payload = _prettyJson.convert(config);
    final bg = theme == 'dark' ? '#131722' : '#ffffff';
    return '''
<!DOCTYPE html>
<html style="height:100%;margin:0;">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<style>
html,body,.wrap{height:100%;width:100%;margin:0;padding:0;overflow:hidden;}
body{background:$bg;}
.tradingview-widget-copyright{display:none!important;}
</style>
</head>
<body>
<div class="wrap tradingview-widget-container">
  <div class="tradingview-widget-container__widget" style="height:100%;width:100%;"></div>
  <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-advanced-chart.js" async>
$payload
  </script>
</div>
</body>
</html>
''';
  }

  /// Minimal intraday chart for order screen — line/area style, no toolbars.
  static String compactIntradayChartHtml({
    required String symbol,
    String theme = 'light',
    String locale = 'zh_CN',
  }) {
    return advancedChartHtml(
      symbol: symbol,
      theme: theme,
      locale: locale,
      interval: '1',
      style: '3',
      hideSideToolbar: true,
      hideTopToolbar: true,
      hideLegend: true,
      hideVolume: true,
      withDateRanges: false,
      saveImage: false,
    );
  }
}
