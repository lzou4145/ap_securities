import 'package:ap_securities/features/market/domain/market_price_format.dart';

/// HTML for [TradingView Lightweight Charts](https://www.tradingview.com/lightweight-charts/)
/// with a bridge to Flutter via `ChartBridge` JavaScript channel.
abstract final class LightweightChartsEmbed {
  static String _priceFormatterJs(int decimalPlace) {
    final places = normalizeDecimalPlace(decimalPlace);
    return '''
  function formatChartPrice(price) {
    if (!Number.isFinite(price)) return '';
    return price.toFixed($places);
  }
''';
  }

  static String _seriesPriceFormatJs(int decimalPlace) {
    final places = normalizeDecimalPlace(decimalPlace);
    final minMove = places == 0 ? '1' : '1e-$places';
    return '''
    priceFormat: { type: 'price', precision: $places, minMove: $minMove },
''';
  }

  /// MQTT chart tab — intraday area line (分时), no volume pane.
  static String intradayChartHtml({
    String locale = 'zh-CN',
    int decimalPlace = 2,
  }) {
    final priceFormatterJs = _priceFormatterJs(decimalPlace);
    final seriesPriceFormatJs = _seriesPriceFormatJs(decimalPlace);
    return '''
<!DOCTYPE html>
<html style="height:100%;margin:0;">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<style>
  html, body, #chart { height: 100%; width: 100%; margin: 0; padding: 0; background: #ffffff; overflow: hidden; }
</style>
<script src="https://unpkg.com/lightweight-charts@4.2.0/dist/lightweight-charts.standalone.production.js"></script>
</head>
<body>
<div id="chart"></div>
<script>
$priceFormatterJs
(function () {
  const container = document.getElementById('chart');
  const chart = LightweightCharts.createChart(container, {
    layout: { background: { color: '#ffffff' }, textColor: '#666' },
    grid: {
      vertLines: { visible: true, color: '#f5f5f5' },
      horzLines: { visible: true, color: '#f5f5f5' },
    },
    rightPriceScale: { borderVisible: false },
    timeScale: {
      borderVisible: false,
      timeVisible: true,
      secondsVisible: false,
      fixLeftEdge: true,
      fixRightEdge: true,
    },
    crosshair: {
      mode: LightweightCharts.CrosshairMode.Magnet,
      vertLine: { visible: true, labelVisible: true },
      horzLine: { visible: true, labelVisible: true },
    },
    handleScroll: { mouseWheel: true, pressedMouseMove: true },
    handleScale: { axisPressedMouseMove: true, mouseWheel: true, pinch: true },
    localization: { locale: '$locale', priceFormatter: formatChartPrice },
  });

  const lineSeries = chart.addAreaSeries({
    $seriesPriceFormatJs
    lineColor: '#017FF7',
    topColor: 'rgba(1, 127, 247, 0.28)',
    bottomColor: 'rgba(1, 127, 247, 0.02)',
    lineWidth: 2,
    priceLineVisible: true,
    lastValueVisible: true,
  });

  let earliestSec = null;

  function post(obj) {
    if (window.ChartBridge && window.ChartBridge.postMessage) {
      window.ChartBridge.postMessage(JSON.stringify(obj));
    }
  }

  window.__chartApi = {
    setBars: function (bars) {
      if (!bars || !bars.length) {
        lineSeries.setData([]);
        earliestSec = null;
        chart.timeScale().fitContent();
        return;
      }
      const points = bars.map(function (b) {
        return { time: b.time, value: b.close };
      });
      lineSeries.setData(points);
      earliestSec = points[0].time;
      chart.timeScale().fitContent();
    },
    scrollToRealtime: function () {
      chart.timeScale().scrollToRealTime();
    },
  };

  chart.timeScale().subscribeVisibleLogicalRangeChange(function (range) {
    if (!range || earliestSec == null) return;
    if (range.from > 8) return;
    const fromMs = (earliestSec - 60) * 1000;
    const toMs = earliestSec * 1000;
    post({ type: 'needHistory', from: fromMs, to: toMs });
  });

  window.addEventListener('resize', function () {
    chart.applyOptions({
      width: container.clientWidth,
      height: container.clientHeight,
    });
  });

  chart.applyOptions({
    width: container.clientWidth,
    height: container.clientHeight,
  });

  post({ type: 'ready' });
})();
</script>
</body>
</html>
''';
  }

  /// Trade order page — intraday bid (blue) / ask (red), live ticks only.
  static String tradeOrderBidAskLineChartHtml({
    String locale = 'zh-CN',
    int decimalPlace = 2,
  }) {
    final priceFormatterJs = _priceFormatterJs(decimalPlace);
    final seriesPriceFormatJs = _seriesPriceFormatJs(decimalPlace);
    return '''
<!DOCTYPE html>
<html style="height:100%;margin:0;">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<style>
  html, body, #chart { height: 100%; width: 100%; margin: 0; padding: 0; background: #ffffff; overflow: hidden; }
  #chart a[href*="tradingview"] { display: none !important; visibility: hidden !important; }
</style>
<script src="https://unpkg.com/lightweight-charts@4.2.0/dist/lightweight-charts.standalone.production.js"></script>
</head>
<body>
<div id="chart"></div>
<script>
$priceFormatterJs
(function () {
  const container = document.getElementById('chart');
  const chart = LightweightCharts.createChart(container, {
    layout: {
      background: { color: '#ffffff' },
      textColor: '#666',
      attributionLogo: false,
    },
    grid: {
      vertLines: { visible: true, color: '#f5f5f5' },
      horzLines: { visible: true, color: '#f5f5f5' },
    },
    rightPriceScale: { borderVisible: false },
    timeScale: {
      visible: false,
      borderVisible: false,
      timeVisible: false,
      secondsVisible: false,
      barSpacing: 8,
      minBarSpacing: 6,
      rightOffset: 2,
      shiftVisibleRangeOnNewBar: true,
    },
    crosshair: {
      mode: LightweightCharts.CrosshairMode.Magnet,
      vertLine: { visible: true, labelVisible: false },
      horzLine: { visible: true, labelVisible: true },
    },
    handleScroll: { mouseWheel: true, pressedMouseMove: true },
    handleScale: { axisPressedMouseMove: true, mouseWheel: true, pinch: true },
    localization: { locale: '$locale', priceFormatter: formatChartPrice },
  });

  const bidSeries = chart.addLineSeries({
    $seriesPriceFormatJs
    color: '#017FF7',
    lineWidth: 2,
    priceLineVisible: false,
    lastValueVisible: true,
    crosshairMarkerVisible: true,
  });
  const askSeries = chart.addLineSeries({
    $seriesPriceFormatJs
    color: '#e53935',
    lineWidth: 2,
    priceLineVisible: false,
    lastValueVisible: true,
    crosshairMarkerVisible: true,
  });

  var lastTimeSec = null;

  function post(obj) {
    if (window.ChartBridge && window.ChartBridge.postMessage) {
      window.ChartBridge.postMessage(JSON.stringify(obj));
    }
  }

  function stickToRight() {
    chart.timeScale().scrollToRealTime();
  }

  window.__chartApi = {
    setBars: function (bars) {
      if (!bars || !bars.length) {
        bidSeries.setData([]);
        askSeries.setData([]);
        lastTimeSec = null;
        return;
      }
      const bidPoints = bars.map(function (b) {
        return { time: b.time, value: b.bid };
      });
      const askPoints = bars.map(function (b) {
        return { time: b.time, value: b.ask };
      });
      bidSeries.setData(bidPoints);
      askSeries.setData(askPoints);
      lastTimeSec = bidPoints[bidPoints.length - 1].time;
      stickToRight();
    },
    updatePoint: function (bar) {
      if (!bar) return;
      const isNewTime = lastTimeSec !== bar.time;
      bidSeries.update({ time: bar.time, value: bar.bid });
      askSeries.update({ time: bar.time, value: bar.ask });
      if (!isNewTime) {
        return;
      }
      lastTimeSec = bar.time;
      stickToRight();
    },
    updateBar: function (bar) {
      window.__chartApi.updatePoint(bar);
    },
    scrollToRealtime: function () {
      stickToRight();
    },
  };

  var lastW = 0;
  var lastH = 0;
  window.addEventListener('resize', function () {
    var w = container.clientWidth;
    var h = container.clientHeight;
    if (w === lastW && h === lastH) return;
    lastW = w;
    lastH = h;
    chart.applyOptions({ width: w, height: h });
  });

  chart.applyOptions({
    width: container.clientWidth,
    height: container.clientHeight,
  });

  post({ type: 'ready' });
})();
</script>
</body>
</html>
''';
  }

  static String chartHtml({
    String locale = 'zh-CN',
    bool hideVolume = false,
    bool isDark = false,
    int decimalPlace = 2,
    String seriesType = 'candles',
    String indicatorsJson = '[]',
    int initialVisibleBars = 70,
    int barDurationMs = 60000,
    int historyBatchBars = 200,
  }) {
    final priceFormatterJs = _priceFormatterJs(decimalPlace);
    final seriesPriceFormatJs = _seriesPriceFormatJs(decimalPlace);
    final pageBg = isDark ? '#131722' : '#ffffff';
    final layoutBg = isDark ? '#131722' : '#ffffff';
    final textColor = isDark ? '#D1D4DC' : '#333333';
    final gridColor = isDark ? '#2A2E39' : '#f0f0f0';
    final borderColor = isDark ? '#2A2E39' : '#e0e0e0';
    final showVolumePane = !hideVolume;

    return '''
<!DOCTYPE html>
<html style="height:100%;margin:0;">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<style>
  html, body, #chart { height: 100%; width: 100%; margin: 0; padding: 0; background: $pageBg; }
  #chart a[href*="tradingview"] { display: none !important; visibility: hidden !important; }
</style>
<script src="https://unpkg.com/lightweight-charts@4.2.0/dist/lightweight-charts.standalone.production.js"></script>
</head>
<body>
<div id="chart"></div>
<script>
$priceFormatterJs
(function () {
  const container = document.getElementById('chart');
  const chart = LightweightCharts.createChart(container, {
    layout: {
      background: { color: '$layoutBg' },
      textColor: '$textColor',
      attributionLogo: false,
    },
    grid: {
      vertLines: { color: '$gridColor' },
      horzLines: { color: '$gridColor' },
    },
    rightPriceScale: { borderColor: '$borderColor' },
    timeScale: {
      borderColor: '$borderColor',
      timeVisible: true,
      secondsVisible: false,
      barSpacing: 10,
      minBarSpacing: 0.5,
      rightOffset: 4,
    },
    handleScroll: { mouseWheel: true, pressedMouseMove: true, horzTouchDrag: true, vertTouchDrag: true },
    handleScale: { axisPressedMouseMove: true, mouseWheel: true, pinch: true },
    crosshair: { mode: LightweightCharts.CrosshairMode.Normal },
    localization: { locale: '$locale', priceFormatter: formatChartPrice },
  });

  let seriesType = '$seriesType';
  let activeIndicators = $indicatorsJson;
  let barStore = [];
  let mainSeries = null;
  let volumeSeries = null;
  const overlaySeries = {};
  let rsiSeries = null;
  let earliestSec = null;
  let hasFitted = false;
  const showVolumePane = $showVolumePane;
  const initialVisibleBars = $initialVisibleBars;
  const barDurationMs = $barDurationMs;
  const historyBatchMs = barDurationMs * $historyBatchBars;

  function post(obj) {
    if (window.ChartBridge && window.ChartBridge.postMessage) {
      window.ChartBridge.postMessage(JSON.stringify(obj));
    }
  }

  function calcSma(bars, period) {
    const out = [];
    for (let i = 0; i < bars.length; i++) {
      if (i + 1 < period) continue;
      let sum = 0;
      for (let j = i - period + 1; j <= i; j++) sum += bars[j].close;
      out.push({ time: bars[i].time, value: sum / period });
    }
    return out;
  }

  function calcEma(bars, period) {
    const out = [];
    const k = 2 / (period + 1);
    let ema = null;
    for (let i = 0; i < bars.length; i++) {
      const close = bars[i].close;
      if (ema == null) {
        if (i + 1 < period) continue;
        let sum = 0;
        for (let j = 0; j < period; j++) sum += bars[j].close;
        ema = sum / period;
        out.push({ time: bars[i].time, value: ema });
        continue;
      }
      ema = close * k + ema * (1 - k);
      out.push({ time: bars[i].time, value: ema });
    }
    return out;
  }

  function calcRsi(bars, period) {
    const out = [];
    if (bars.length < period + 1) return out;
    let avgGain = 0;
    let avgLoss = 0;
    for (let i = 1; i <= period; i++) {
      const diff = bars[i].close - bars[i - 1].close;
      if (diff >= 0) avgGain += diff; else avgLoss -= diff;
    }
    avgGain /= period;
    avgLoss /= period;
    const rs0 = avgLoss === 0 ? 100 : avgGain / avgLoss;
    out.push({ time: bars[period].time, value: 100 - 100 / (1 + rs0) });
    for (let i = period + 1; i < bars.length; i++) {
      const diff = bars[i].close - bars[i - 1].close;
      const gain = diff > 0 ? diff : 0;
      const loss = diff < 0 ? -diff : 0;
      avgGain = (avgGain * (period - 1) + gain) / period;
      avgLoss = (avgLoss * (period - 1) + loss) / period;
      const rs = avgLoss === 0 ? 100 : avgGain / avgLoss;
      out.push({ time: bars[i].time, value: 100 - 100 / (1 + rs) });
    }
    return out;
  }

  function toMainData(type, bars) {
    if (!bars || !bars.length) return [];
    if (type === 'line' || type === 'area') {
      return bars.map(function (b) { return { time: b.time, value: b.close }; });
    }
    return bars.map(function (b) {
      return {
        time: b.time,
        open: b.open,
        high: b.high,
        low: b.low,
        close: b.close,
      };
    });
  }

  function removeMainSeries() {
    if (mainSeries) {
      chart.removeSeries(mainSeries);
      mainSeries = null;
    }
  }

  function createMainSeries(type) {
    removeMainSeries();
    if (type === 'line') {
      mainSeries = chart.addLineSeries({
        $seriesPriceFormatJs
        color: '#017FF7',
        lineWidth: 2,
      });
      return;
    }
    if (type === 'area') {
      mainSeries = chart.addAreaSeries({
        $seriesPriceFormatJs
        lineColor: '#017FF7',
        topColor: 'rgba(1, 127, 247, 0.28)',
        bottomColor: 'rgba(1, 127, 247, 0.02)',
        lineWidth: 2,
      });
      return;
    }
    if (type === 'bars') {
      mainSeries = chart.addBarSeries({
        $seriesPriceFormatJs
        upColor: '#e53935',
        downColor: '#2e7d32',
      });
      return;
    }
    if (type === 'hollowCandles') {
      mainSeries = chart.addCandlestickSeries({
        $seriesPriceFormatJs
        upColor: 'rgba(0, 0, 0, 0)',
        downColor: '#2e7d32',
        borderUpColor: '#e53935',
        borderDownColor: '#2e7d32',
        wickUpColor: '#e53935',
        wickDownColor: '#2e7d32',
      });
      return;
    }
    mainSeries = chart.addCandlestickSeries({
      $seriesPriceFormatJs
      upColor: '#e53935',
      downColor: '#2e7d32',
      borderUpColor: '#e53935',
      borderDownColor: '#2e7d32',
      wickUpColor: '#e53935',
      wickDownColor: '#2e7d32',
    });
  }

  function ensureVolumeSeries() {
    if (!showVolumePane) return;
    const showVol = seriesType === 'candles'
      || seriesType === 'hollowCandles'
      || seriesType === 'bars';
    if (!showVol) {
      if (volumeSeries) {
        chart.removeSeries(volumeSeries);
        volumeSeries = null;
      }
      chart.priceScale('right').applyOptions({
        scaleMargins: {
          top: 0.05,
          bottom: activeIndicators.indexOf('rsi14') >= 0 ? 0.32 : 0.05,
        },
      });
      return;
    }
    if (!volumeSeries) {
      volumeSeries = chart.addHistogramSeries({
        priceFormat: { type: 'volume' },
        priceScaleId: 'volume',
      });
      chart.priceScale('volume').applyOptions({
        scaleMargins: { top: 0.78, bottom: 0 },
      });
    }
    chart.priceScale('right').applyOptions({
      scaleMargins: {
        top: 0.05,
        bottom: activeIndicators.indexOf('rsi14') >= 0 ? 0.32 : 0.22,
      },
    });
  }

  function setVolumeData(bars) {
    ensureVolumeSeries();
    if (!volumeSeries || !bars || !bars.length) return;
    volumeSeries.setData(bars.map(function (b) {
      return {
        time: b.time,
        value: b.volume || 0,
        color: b.close >= b.open
          ? 'rgba(229,57,53,0.35)'
          : 'rgba(46,125,50,0.35)',
      };
    }));
  }

  function clearOverlays() {
    Object.keys(overlaySeries).forEach(function (key) {
      chart.removeSeries(overlaySeries[key]);
      delete overlaySeries[key];
    });
    if (rsiSeries) {
      chart.removeSeries(rsiSeries);
      rsiSeries = null;
    }
  }

  function applyIndicators() {
    clearOverlays();
    if (!barStore.length) return;
    if (activeIndicators.indexOf('ma20') >= 0) {
      overlaySeries.ma20 = chart.addLineSeries({
        color: '#FFA726',
        lineWidth: 1,
        priceLineVisible: false,
        lastValueVisible: false,
      });
      overlaySeries.ma20.setData(calcSma(barStore, 20));
    }
    if (activeIndicators.indexOf('ema12') >= 0) {
      overlaySeries.ema12 = chart.addLineSeries({
        color: '#AB47BC',
        lineWidth: 1,
        priceLineVisible: false,
        lastValueVisible: false,
      });
      overlaySeries.ema12.setData(calcEma(barStore, 12));
    }
    if (activeIndicators.indexOf('rsi14') >= 0) {
      rsiSeries = chart.addLineSeries({
        color: '#7E57C2',
        lineWidth: 1,
        priceScaleId: 'rsi',
        priceLineVisible: false,
        lastValueVisible: false,
      });
      chart.priceScale('rsi').applyOptions({
        scaleMargins: { top: 0.82, bottom: 0.02 },
      });
      rsiSeries.setData(calcRsi(barStore, 14));
    }
  }

  function renderAll() {
    createMainSeries(seriesType);
    if (!barStore.length) {
      if (mainSeries) mainSeries.setData([]);
      if (volumeSeries) volumeSeries.setData([]);
      clearOverlays();
      return;
    }
    mainSeries.setData(toMainData(seriesType, barStore));
    setVolumeData(barStore);
    applyIndicators();
  }

  createMainSeries(seriesType);

  function applyDefaultVisibleRange() {
    const n = barStore.length;
    if (n < 2) {
      chart.timeScale().fitContent();
      return;
    }
    const visible = Math.min(initialVisibleBars, n);
    chart.timeScale().setVisibleLogicalRange({
      from: n - visible,
      to: n + 1,
    });
  }

  window.__chartApi = {
    setBars: function (bars) {
      barStore = bars || [];
      if (!barStore.length) {
        earliestSec = null;
        hasFitted = false;
        renderAll();
        return;
      }
      earliestSec = barStore[0].time;
      renderAll();
      if (!hasFitted) {
        applyDefaultVisibleRange();
        hasFitted = true;
      }
    },
    updateBar: function (bar) {
      if (!bar) return;
      if (!barStore.length) {
        barStore = [bar];
      } else if (barStore[barStore.length - 1].time === bar.time) {
        barStore[barStore.length - 1] = bar;
      } else {
        barStore.push(bar);
      }
      if (seriesType === 'line' || seriesType === 'area') {
        mainSeries.update({ time: bar.time, value: bar.close });
      } else {
        mainSeries.update({
          time: bar.time,
          open: bar.open,
          high: bar.high,
          low: bar.low,
          close: bar.close,
        });
      }
      if (volumeSeries) {
        volumeSeries.update({
          time: bar.time,
          value: bar.volume || 0,
          color: bar.close >= bar.open
            ? 'rgba(229,57,53,0.35)'
            : 'rgba(46,125,50,0.35)',
        });
      }
      applyIndicators();
    },
    setSeriesType: function (type) {
      seriesType = type;
      renderAll();
    },
    setIndicators: function (list) {
      activeIndicators = list || [];
      applyIndicators();
      ensureVolumeSeries();
      if (barStore.length) setVolumeData(barStore);
    },
    fitContent: function () {
      chart.timeScale().fitContent();
    },
    scrollToRealtime: function () {
      chart.timeScale().scrollToRealTime();
    },
  };

  chart.timeScale().subscribeVisibleLogicalRangeChange(function (range) {
    if (!range || earliestSec == null) return;
    if (range.from > 8) return;
    const toMs = earliestSec * 1000;
    const fromMs = Math.max(0, toMs - historyBatchMs);
    if (fromMs >= toMs) return;
    post({ type: 'needHistory', from: fromMs, to: toMs });
  });

  var lastW = 0;
  var lastH = 0;
  window.addEventListener('resize', function () {
    var w = container.clientWidth;
    var h = container.clientHeight;
    if (w === lastW && h === lastH) return;
    lastW = w;
    lastH = h;
    chart.applyOptions({ width: w, height: h });
  });

  chart.applyOptions({
    width: container.clientWidth,
    height: container.clientHeight,
  });

  post({ type: 'ready' });
})();
</script>
</body>
</html>
''';
  }
}
