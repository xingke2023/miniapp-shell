// pages/chat/chat.js
// 不使用 async/await，避免微信开发者工具触发 @babel/runtime 转译。
var api = require('../../utils/api.js');

var _msgId = 0;
function nextId() { return 'm' + (++_msgId); }

// 窗口信息：优先用新版 wx.getWindowInfo（含 statusBarHeight/windowWidth/windowHeight），
// 老基础库回退 wx.getSystemInfoSync。替代已废弃的 getSystemInfoSync 直接调用。
function getWin() {
  if (wx.getWindowInfo) { return wx.getWindowInfo(); }
  if (wx.getSystemInfoSync) { return wx.getSystemInfoSync(); }
  return {};
}

// ─── 查询类卡片 → markdown 文本（舌尖后端 query intent 的 reply 仅为占位，数据在 card_data）──
function fmtNum(v) {
  var n = Number(v);
  if (isNaN(n)) { return String(v == null ? '' : v); }
  return (Math.round(n * 1000) / 1000).toString();
}

function cardToMarkdown(cardType, cardData) {
  if (!cardData) { return ''; }
  var d = cardData;
  var lines = [];
  var i, j, it, list;

  if (cardType === 'inventory') {
    list = d.data || (Array.isArray(d) ? d : []);
    if (!list.length) { return '暂无库存数据。'; }
    lines.push('📦 **当前库存**');
    for (i = 0; i < list.length; i++) {
      it = list[i];
      var iname = (it.product && it.product.name) || it.product_name || '-';
      var iunit = (it.product && it.product.unit) || it.unit || '';
      var q = Number(it.current_qty);
      var flag = q === 0 ? '（售罄）' : (q < 5 ? '（偏少）' : '');
      lines.push('- ' + iname + '：' + fmtNum(it.current_qty) + iunit + flag);
    }
    return lines.join('\n');
  }

  if (cardType === 'sales_today' || cardType === 'sales_report') {
    var s = d.data || d || {};
    lines.push('💰 **今日销售**');
    var amt = Number(s.total_amount || 0);
    var tqty = Number(s.total_qty || 0);
    lines.push('- 营业额：' + (amt > 0 ? '¥' + amt.toFixed(2) : '—'));
    if (tqty > 0) { lines.push('- 出库总量：' + fmtNum(tqty) + ' 斤'); }
    lines.push('- 订单数：' + (s.total_orders || 0));
    var pay = s.payment_breakdown || {};
    var payLabels = { '1': '现金', '2': '微信', '3': '支付宝', '4': '银行卡', '5': '混合' };
    var payKeys = Object.keys(pay);
    if (payKeys.length) {
      lines.push('');
      lines.push('**支付方式**');
      for (i = 0; i < payKeys.length; i++) {
        lines.push('- ' + (payLabels[payKeys[i]] || payKeys[i]) + '：¥' + Number(pay[payKeys[i]]).toFixed(2));
      }
    }
    return lines.join('\n');
  }

  if (cardType === 'daily_overview') {
    list = (d.data && d.data.products) || (d.data && d.data.length ? d.data : (Array.isArray(d) ? d : []));
    if (!list || !list.length) { return '今日暂无营运数据。'; }
    lines.push('📊 **每日营运概览**');
    lines.push('（开盘 +进货 -销售 = 结余）');
    for (i = 0; i < list.length; i++) {
      it = list[i];
      var onm = it.product_name || (it.product && it.product.name) || '-';
      lines.push('- ' + onm + '：' + fmtNum(it.opening_qty || 0) + ' +' + fmtNum(it.received_qty || 0) +
        ' -' + fmtNum(it.sold_qty || 0) + ' = **' + fmtNum(it.closing_qty || 0) + '**' + (it.sold_out_at ? ' 🔴售罄' : ''));
    }
    return lines.join('\n');
  }

  if (cardType === 'purchase_orders') {
    list = d.data || (Array.isArray(d) ? d : []);
    if (!list.length) { return '今日暂无进货单。'; }
    var stMap = { '1': '待处理', '2': '已确认', '3': '已收货', '4': '已取消' };
    lines.push('🚚 **进货单**');
    for (i = 0; i < list.length; i++) {
      var o = list[i];
      lines.push('');
      lines.push('**进货单 #' + o.id + '** · ' + (stMap[o.status] || o.status) + (o.date ? ' · ' + o.date : ''));
      var oitems = o.items || [];
      for (j = 0; j < oitems.length; j++) {
        var pi = oitems[j];
        var pn = (pi.product && pi.product.name) || pi.product_name || '-';
        lines.push('- ' + pn + ' ' + fmtNum(pi.ordered_qty) + (pi.unit || '') + (pi.unit_price ? ' × ¥' + pi.unit_price : ''));
      }
    }
    return lines.join('\n');
  }

  if (cardType === 'daily_logs') {
    list = d.data || (Array.isArray(d) ? d : []);
    if (!list.length) { return '今日暂无操作记录。'; }
    var srcMap = { '1': 'AI', '2': '手动', '3': '后台' };
    lines.push('📝 **今日操作日志**');
    for (i = 0; i < list.length; i++) {
      var lg = list[i];
      var ts = lg.created_at ? String(lg.created_at).replace('T', ' ').slice(11, 16) : '';
      var content = lg.content || lg.message || lg.intent || '-';
      lines.push('- ' + (ts ? '`' + ts + '` ' : '') + '[' + (srcMap[lg.source] || '?') + '] ' + content);
    }
    return lines.join('\n');
  }

  if (cardType === 'weather') {
    var meta = d || {};
    var w = meta.data || meta || {};
    var city = meta.city || w.city || '香港';
    var date = meta.date || w.date || '';
    var th = w.temperature_high != null ? w.temperature_high : (w.temperature != null ? w.temperature : null);
    var tl = w.temperature_low != null ? w.temperature_low : null;
    var temp = th != null ? (tl != null ? tl + '°~' + th + '°' : th + '°') : '';
    var cond = w.condition || w.weather || w.description || '';
    lines.push('🌦️ **' + city + ' 天气**' + (date ? ' · ' + date : ''));
    if (temp) { lines.push('- 气温：' + temp); }
    if (cond) { lines.push('- 天气：' + cond); }
    if (w.rain_probability != null) { lines.push('- 降水概率：' + w.rain_probability + '%'); }
    if (w.suggestion) { lines.push(''); lines.push('💡 ' + w.suggestion); }
    return lines.join('\n');
  }

  if (cardType === 'suggestions') {
    var inner = d.data || d || {};
    var pur = inner.purchase_suggestions || [];
    var promo = inner.promo_suggestions || [];
    var uMap = { urgent: '🔴紧急', high: '🟠重要', medium: '🟡建议', low: '参考' };
    lines.push('💡 **经营建议**');
    lines.push('');
    lines.push('🚛 **进货建议**');
    if (!pur.length) { lines.push('- 暂无，库存充足'); }
    for (i = 0; i < pur.length; i++) {
      it = pur[i];
      lines.push('- ' + (uMap[it.urgency] || '') + ' **' + it.product_name + '**（余' + fmtNum(it.current_qty || 0) +
        (it.unit || '') + '）：' + (it.action || it.reason || ''));
    }
    lines.push('');
    lines.push('🎯 **促销建议**');
    if (!promo.length) { lines.push('- 暂无，销售正常'); }
    for (i = 0; i < promo.length; i++) {
      it = promo[i];
      lines.push('- ' + (uMap[it.urgency] || '') + ' **' + it.product_name + '**：' + (it.action || it.reason || ''));
    }
    return lines.join('\n');
  }

  return '';
}

// ─── 内联 SVG 图标（WeChat / WeUI 风格，细线 24x24，URL-encoded data URI）──
function svgIcon(svg) { return 'data:image/svg+xml;utf8,' + encodeURIComponent(svg); }
var ICON_STROKE = '%232A1F19'; // #2A1F19
var ICON_RED = '%23E65C46';
function feather(path, color) {
  if (!color) color = '#2A1F19';
  return svgIcon('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="' + color + '" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' + path + '</svg>');
}
function botSvg(color) {
  return svgIcon(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="' + color + '" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">' +
    // 天线
    '<line x1="12" y1="1.8" x2="12" y2="4.6"/>' +
    '<circle cx="12" cy="1.4" r="1.1" fill="' + color + '" stroke="none"/>' +
    // 头部
    '<rect x="3.5" y="5.5" width="17" height="14" rx="4"/>' +
    // 耳部凸块
    '<rect x="1" y="10" width="2.5" height="3.5" rx="1.2"/>' +
    '<rect x="20.5" y="10" width="2.5" height="3.5" rx="1.2"/>' +
    // 左眼（轮廓圆 + 实心瞳孔）
    '<circle cx="8.8" cy="11.5" r="2.1"/>' +
    '<circle cx="8.8" cy="11.5" r="0.85" fill="' + color + '" stroke="none"/>' +
    // 右眼
    '<circle cx="15.2" cy="11.5" r="2.1"/>' +
    '<circle cx="15.2" cy="11.5" r="0.85" fill="' + color + '" stroke="none"/>' +
    // 微笑
    '<path d="M8.8 15.4 Q12 17.6 15.2 15.4"/>' +
    '</svg>'
  );
}
var ICONS = {
  mic: feather('<path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"/><path d="M19 10v2a7 7 0 0 1-14 0v-2"/><line x1="12" y1="19" x2="12" y2="23"/><line x1="8" y1="23" x2="16" y2="23"/>'),
  keyboard: feather('<rect x="2" y="6" width="20" height="12" rx="2"/><line x1="6" y1="10" x2="6.01" y2="10"/><line x1="10" y1="10" x2="10.01" y2="10"/><line x1="14" y1="10" x2="14.01" y2="10"/><line x1="18" y1="10" x2="18.01" y2="10"/><line x1="6" y1="14" x2="6.01" y2="14"/><line x1="18" y1="14" x2="18.01" y2="14"/><line x1="10" y1="14" x2="14" y2="14"/>'),
  plus: feather('<line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>'),
  close: feather('<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>'),
  camera: feather('<path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/>'),
  album: feather('<rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/>'),
  file: feather('<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><line x1="10" y1="9" x2="9" y2="9"/><line x1="10" y1="9" x2="8" y2="9"/>'),
  arrowUp: feather('<line x1="12" y1="19" x2="12" y2="5"/><polyline points="5 12 12 5 19 12"/>', '#FFFFFF'),
  bot: botSvg('#E65C46'),       // 红色版（用于白色圆形头像内部）
  botWhite: botSvg('#FFFFFF'),  // 白色版（用于红色按钮等深色背景）
  // 子菜单轮廓图标
  chartBar:    feather('<line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/>'),
  trendingUp:  feather('<polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/>'),
  upload:      feather('<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/>'),
  truck:       feather('<rect x="1" y="3" width="15" height="13"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/>'),
  zap:         feather('<polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>'),
  clipboard:   feather('<path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><rect x="8" y="2" width="8" height="4" rx="1" ry="1"/>'),
  package:     feather('<line x1="16.5" y1="9.4" x2="7.5" y2="4.21"/><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/>'),
  dollarSign:  feather('<line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>'),
  shoppingBag: feather('<path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/>'),
  alertCircle: feather('<circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>'),
  settings:    feather('<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>'),
  trash:       feather('<polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/>'),
  // 主菜单胶囊图标
  home:    feather('<path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/>'),
  tool:    feather('<path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/>'),
  cpu:     feather('<rect x="4" y="4" width="16" height="16" rx="2"/><rect x="9" y="9" width="6" height="6"/><line x1="9" y1="1" x2="9" y2="4"/><line x1="15" y1="1" x2="15" y2="4"/><line x1="20" y1="9" x2="23" y2="9"/><line x1="20" y1="14" x2="23" y2="14"/><line x1="1" y1="9" x2="4" y2="9"/><line x1="1" y1="14" x2="4" y2="14"/>'),
  image:   feather('<rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/>'),
  monitor: feather('<rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/>'),
};

// 快捷胶囊专用蓝色图标（同路径，换色 #1A6DB5）
var BLUE = '#1A6DB5';
var ICONS_BLUE = {
  chartBar:   feather('<line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/>', BLUE),
  trendingUp: feather('<polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/>', BLUE),
  upload:     feather('<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/>', BLUE),
  truck:      feather('<rect x="1" y="3" width="15" height="13"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/>', BLUE),
  zap:        feather('<polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>', BLUE),
  clipboard:  feather('<path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><rect x="8" y="2" width="8" height="4" rx="1" ry="1"/>', BLUE),
  package:    feather('<line x1="16.5" y1="9.4" x2="7.5" y2="4.21"/><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/>', BLUE),
  dollarSign: feather('<line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>', BLUE),
  trash:      feather('<polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/>', BLUE),
  settings:   feather('<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>', BLUE),
  home:    feather('<path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/>', BLUE),
  tool:    feather('<path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/>', BLUE),
  cpu:     feather('<rect x="4" y="4" width="16" height="16" rx="2"/><rect x="9" y="9" width="6" height="6"/><line x1="9" y1="1" x2="9" y2="4"/><line x1="15" y1="1" x2="15" y2="4"/><line x1="20" y1="9" x2="23" y2="9"/><line x1="20" y1="14" x2="23" y2="14"/><line x1="1" y1="9" x2="4" y2="9"/><line x1="1" y1="14" x2="4" y2="14"/>', BLUE),
  image:   feather('<rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/>', BLUE),
  monitor: feather('<rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/>', BLUE),
};

var EMOJI_ICON_MAP = {
  '📊': 'chartBar', '📈': 'trendingUp', '📤': 'upload', '🚚': 'truck',
  '💡': 'zap',      '📝': 'clipboard',  '📦': 'package', '💰': 'dollarSign',
  '🛍': 'shoppingBag', '🛒': 'shoppingBag', '⚙️': 'settings', '⚠️': 'alertCircle',
  '🗑️': 'trash', '🗑': 'trash',
  '🏠': 'home', '🔧': 'tool', '🤖': 'cpu', '🎨': 'image', '🧑‍💻': 'monitor',
};

// ─── Markdown → HTML (轻量版，给 rich-text 用) ──────────────────────────────
function escapeHtml(s) {
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

/**
 * 把 markdown 文本解析成结构化块数组，由 wxml 逐块渲染。
 * 块类型：
 *   { type:'h',  level:1|2|3, html:'...' }
 *   { type:'li', ordered:bool, marker:'1.' | '•', html:'...' }
 *   { type:'code', text:'...' }
 *   { type:'p',  html:'...' }    // 包含可选的 <br>
 * inline html 仅含: <strong> <em> <code> <span style="link"> <br>
 */
function inlineMd(s) {
  if (s == null) return '';
  s = String(s);
  // inline code 先抽出（防止后续转义破坏）
  var codes = [];
  s = s.replace(/`([^`\n]+)`/g, function (_m, c) {
    codes.push(c);
    return ' IC' + (codes.length - 1) + ' ';
  });
  // 转义 HTML 特殊字符
  s = s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  // 加粗
  s = s.replace(/\*\*([^*\n]+)\*\*/g, '<strong>$1</strong>');
  s = s.replace(/__([^_\n]+)__/g, '<strong>$1</strong>');
  // 斜体
  s = s.replace(/\*([^*\n]+)\*/g, '<em>$1</em>');
  // 链接（仅视觉，rich-text 不能跳）
  s = s.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<span style="color:#E65C46;text-decoration:underline;">$1</span>');
  // 还原 inline code
  s = s.replace(/ IC(\d+) /g, function (_m, i) {
    var c = codes[+i].replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    return '<code style="background:rgba(42,31,25,0.10);padding:1rpx 8rpx;border-radius:6rpx;font-family:monospace;font-size:0.92em;">' + c + '</code>';
  });
  return s;
}

function mdParse(text) {
  if (!text) return [];
  var raw = String(text);

  // 1. 抽出 fenced code block
  var codeBlocks = [];
  raw = raw.replace(/```(\w+)?\n?([\s\S]*?)```/g, function (_m, lang, content) {
    if (lang === 'card') {
      var parsed = null;
      try { parsed = JSON.parse(String(content).trim()); } catch (eP) { /* ignore */ }
      if (parsed && typeof parsed === 'object') {
        codeBlocks.push({ kind: 'card', data: parsed });
        return 'CB' + (codeBlocks.length - 1) + '';
      }
    }
    codeBlocks.push({ kind: 'code', text: String(content) });
    return 'CB' + (codeBlocks.length - 1) + '';
  });

  var blocks = [];
  var lines = raw.split('\n');
  var pBuf = []; // 累积普通段落的多行
  var orderedCounter = 0;

  function flushParagraph() {
    if (pBuf.length === 0) return;
    var joined = pBuf.join('\n');
    // 把段落里的 \n 转成 <br>
    var html = inlineMd(joined).replace(/\n/g, '<br>');
    blocks.push({ type: 'p', html: html });
    pBuf = [];
  }

  for (var i = 0; i < lines.length; i++) {
    var line = lines[i];

    // 代码块占位符 → 独立块（可能是普通代码块，也可能是 card 卡片）
    var cbm = line.match(/CB(\d+)/);
    if (cbm) {
      flushParagraph();
      var entry = codeBlocks[+cbm[1]];
      if (entry && entry.kind === 'card') {
        blocks.push({ type: 'card', data: entry.data });
      } else {
        blocks.push({ type: 'code', text: (entry && entry.text) || '' });
      }
      continue;
    }

    // 标题
    var hm = line.match(/^(#{1,3})\s+(.+)$/);
    if (hm) {
      flushParagraph();
      blocks.push({ type: 'h', level: hm[1].length, html: inlineMd(hm[2]) });
      continue;
    }

    // 有序列表
    var olm = line.match(/^\s*(\d+)\.\s+(.+)$/);
    if (olm) {
      flushParagraph();
      blocks.push({ type: 'li', ordered: true, marker: olm[1] + '.', html: inlineMd(olm[2]) });
      continue;
    }

    // 无序列表
    var ulm = line.match(/^\s*[-*]\s+(.+)$/);
    if (ulm) {
      flushParagraph();
      blocks.push({ type: 'li', ordered: false, marker: '•', html: inlineMd(ulm[1]) });
      continue;
    }

    // 空行 → 段落分隔
    if (line.trim() === '') {
      flushParagraph();
      continue;
    }

    // 其它：累积为段落
    pBuf.push(line);
  }
  flushParagraph();

  // 计算 ordered list 的 marker 最大宽度（保证对齐）
  var maxOrderedDigits = 1;
  for (var k = 0; k < blocks.length; k++) {
    var b = blocks[k];
    if (b.type === 'li' && b.ordered) {
      var n = b.marker.length;
      if (n > maxOrderedDigits) maxOrderedDigits = n;
    }
  }
  for (var j = 0; j < blocks.length; j++) {
    blocks[j].k = 'b' + j; // 每个块唯一 key，避免 wx:key 用对象导致 "[object Object]" 冲突
    if (blocks[j].type === 'li') {
      blocks[j].markerWidth = blocks[j].ordered
        ? Math.max(48, maxOrderedDigits * 18 + 8) + 'rpx'  // 18rpx/位
        : '36rpx';
    }
  }

  return blocks;
}

function mdToHtml(text) {
  if (!text) return '';
  var s = String(text);

  // 1. 先抽出 ```code block```（避免里面的字符被转义/被其它规则破坏）
  var codeBlocks = [];
  s = s.replace(/```([\s\S]*?)```/g, function (_m, code) {
    codeBlocks.push(code.replace(/^[a-zA-Z0-9_-]+\n/, ''));
    return 'CB' + (codeBlocks.length - 1) + '';
  });

  // 2. 抽出 `inline code`
  var inlineCodes = [];
  s = s.replace(/`([^`\n]+)`/g, function (_m, code) {
    inlineCodes.push(code);
    return 'IC' + (inlineCodes.length - 1) + '';
  });

  // 3. 转义剩余 HTML 特殊字符
  s = escapeHtml(s);

  // 4. 标题（行起始 # / ## / ###）
  s = s.replace(/(^|\n)### (.+)/g, '$1<h3 style="font-size:30rpx;font-weight:700;margin:10rpx 0 6rpx;">$2</h3>');
  s = s.replace(/(^|\n)## (.+)/g,  '$1<h2 style="font-size:34rpx;font-weight:700;margin:12rpx 0 8rpx;">$2</h2>');
  s = s.replace(/(^|\n)# (.+)/g,   '$1<h1 style="font-size:38rpx;font-weight:700;margin:14rpx 0 10rpx;">$2</h1>');

  // 5. 加粗 / 斜体（先 ** 后 *）
  s = s.replace(/\*\*([^*\n]+)\*\*/g, '<strong style="font-weight:700;">$1</strong>');
  s = s.replace(/__([^_\n]+)__/g,     '<strong style="font-weight:700;">$1</strong>');
  s = s.replace(/\*([^*\n]+)\*/g,     '<em style="font-style:italic;">$1</em>');

  // 6. 列表 —— 用文本内 marker + paragraph 缩进，避免 rich-text 不支持 list-style counter
  //    无序：•  有序：保留原数字
  //    text-indent 负值 + padding-left 实现"挂起缩进"
  s = s.replace(/(^|\n)[-*] (.+)/g,
    '$1<p style="margin:6rpx 0;padding-left:44rpx;text-indent:-28rpx;">•&nbsp;&nbsp;$2</p>');
  s = s.replace(/(^|\n)(\d+)\.\s+(.+)/g,
    '$1<p style="margin:6rpx 0;padding-left:56rpx;text-indent:-44rpx;"><span style="display:inline-block;width:44rpx;text-align:right;">$2.</span>&nbsp;$3</p>');

  // 7. 链接 [text](url) —— rich-text 不会真的跳转，仅作为视觉
  s = s.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<span style="color:#E65C46;text-decoration:underline;">$1</span>');

  // 8. 收掉 block 元素紧邻的一个 \n（保留剩余 \n 用作段落分隔变 <br>）
  s = s.replace(/\n(<\/?(?:p|h[1-3]|li)[^>]*>)/g, '$1');
  s = s.replace(/(<\/(?:p|h[1-3]|li)>)\n/g, '$1');

  // 9. 剩余换行 → <br>
  s = s.replace(/\n/g, '<br>');

  // 9. 还原 inline code
  s = s.replace(/IC(\d+)/g, function (_m, i) {
    return '<code style="background:rgba(42,31,25,0.08);padding:2rpx 8rpx;border-radius:6rpx;font-family:monospace;font-size:0.92em;">' + escapeHtml(inlineCodes[+i]) + '</code>';
  });

  // 10. 还原代码块
  s = s.replace(/CB(\d+)/g, function (_m, i) {
    var code = escapeHtml(codeBlocks[+i]).replace(/\n/g, '<br>');
    return '<pre style="background:rgba(42,31,25,0.08);padding:14rpx 18rpx;border-radius:12rpx;font-family:monospace;font-size:24rpx;overflow:auto;margin:8rpx 0;"><code>' + code + '</code></pre>';
  });

  return s;
}

Page({
  data: {
    statusBarHeight: 0,
    appTitle: 'AI落地应用', // 顶部标题，后台 app_config miniprogram_title 可覆盖
    user: null,
    logging: false,
    loginForm: { username: '', password: '' },
    isRegisterMode: false, // false=登录表单，true=注册表单（复用同一组输入框）

    externalMode: false,          // 外部行业：菜单/AI 走外部后端，JWT 来自 industry.apiToken
    mediaEnabled: false,          // 聊天是否显示语音/拍照/相册/文件输入（本地行业或 ai_media 行业）

    msgs: [],
    typing: false,
    fontSize: 'lg',

    chatInput: '',
    aiBusy: false,

    scrollAnchor: 'anchor-bottom',
    msgsHeight: 400,

    plusOpen: false,
    voiceMode: false,
    recording: false,

    icons: ICONS,

    // 快捷功能菜单。badge 可以是数字（'3'）或字符（'NEW'），留空则不显示。
    // 点击后 prompt 直接作为用户消息发出去，AI 来响应。
    // 若 items 非空，则改为弹出底部子菜单，由用户选择具体子项。
    quickActions: [],  // 从后台 /api/quick-actions 动态加载，不写死默认值

    // 经营报表 — 锚定在 chip 上方的 popover
    reportMenuOpen: false,
    reportMenuKey: '',
    reportMenuItems: [],
    reportMenuStyle: '',     // popover 容器定位 (px)
    reportMenuArrowStyle: '',// 小三角横向偏移 (px)
  },

  onLoad: function () {
    var app = getApp();

    var sys = getWin();
    this.setData({
      statusBarHeight: sys.statusBarHeight || 20,
      msgsHeight: (sys.windowHeight || 600) - 140,
    });

    this._sessionId = null;

    if (!app.globalData.industry) {
      app.globalData.industry = { slug: 'fresh' };
    }
    var ind = app.globalData.industry;
    // 外部行业（如进销存及CRM）：菜单/标题/接口走外部后端（app2），是纯菜单启动器，
    // 无 AI、不依赖本项目登录；隐藏输入框/登录表单，菜单按钮 web-view 打开外部页。
    var externalMode = !!(ind && ind.apiBase);
    // mediaEnabled：聊天是否显示语音/拍照/相册/文件输入。
    // 本地行业(生鲜)默认开；外部行业(如进销存CRM)需 ai_media=true 才开。
    var mediaEnabled = !externalMode || !!(ind && ind.aiMedia);
    this.setData({ externalMode: externalMode, mediaEnabled: mediaEnabled });

    // 标题优先用所选行业的品牌标题（app_config 作兜底默认）
    if (ind.title) {
      this.setData({ appTitle: ind.title });
    }

    // 应用配置（标题等）——公开接口，登录前也拉取
    this._loadAppConfig();

    // 开启右上角「…」菜单里的转发给朋友 / 分享到朋友圈
    if (wx.showShareMenu) {
      wx.showShareMenu({ withShareTicket: false, menus: ['shareAppMessage', 'shareTimeline'] });
    }

    if (externalMode) {
      this.setData({ user: null });
      if (!ind.apiToken) {
        // 后台未配置服务账号 token，提示管理员
        this._pushAi('⚠️ 此行业尚未配置服务账号，请联系管理员在后台填写「外部服务账号 Token」。');
        wx.nextTick(this._recomputeMsgsHeight.bind(this));
      } else {
        this._greetExternal();
      }
      this._loadQuickActions();
      return;
    }

    // 只有 token + user 都在才算登录；并后台校验 token 是否仍有效
    if (app.globalData.token && app.globalData.user) {
      this.setData({ user: app.globalData.user });
      this._greetLoggedIn(app.globalData.user);
      this._validateSession();
      this._loadQuickActions();
    } else {
      // 无缓存登录态：直接展示登录表单，由用户输入自己的账号密码走 SSO 登录
    }
  },

  // 外部行业欢迎语
  _greetExternal: function () {
    var app = getApp();
    var ind = app.globalData.industry || {};
    // 优先用后台配置的行业欢迎语，留空再用通用兜底
    var greeting = ind.greeting
      || ('欢迎使用 ' + (ind.title || '外部行业') + '！可点菜单进入各功能，也可在输入框直接查询数据。');
    this._pushAi(greeting);
    wx.nextTick(this._recomputeMsgsHeight.bind(this));
  },

  // 校验缓存的 token 是否仍有效，失效则清空登录态、展示登录表单
  _validateSession: function () {
    var self = this;
    api.me().catch(function (err) {
      var msg = (err && err.message) || '';
      if (msg === 'Unauthenticated') {
        self.setData({ user: null, msgs: [] });
        wx.nextTick(function () { self._recomputeMsgsHeight(); });
      }
    });
  },

  // 拉取应用配置（标题等）；失败则保留 data 里的默认标题。
  // 若已选行业且带品牌标题，则以行业标题为准，不被全局 miniprogram_title 覆盖。
  _loadAppConfig: function () {
    var self = this;
    var ind = getApp().globalData.industry;
    // 外部行业：标题由外部后端（app2）设置，从其 app-config 拉取
    if (ind && ind.apiBase) {
      api.appConfig(ind.apiBase).then(function (res) {
        var cfg = (res && res.data) || {};
        if (cfg.miniprogram_title) {
          self.setData({ appTitle: cfg.miniprogram_title });
        }
      }).catch(function () { /* 保留行业默认标题 */ });
      return;
    }
    if (ind && ind.title) { return; } // 行业标题优先，跳过全局配置
    api.appConfig().then(function (res) {
      var cfg = (res && res.data) || {};
      if (cfg.miniprogram_title) {
        self.setData({ appTitle: cfg.miniprogram_title });
      }
    }).catch(function () { /* 保留默认标题 */ });
  },

  // 从后台拉取底部快捷按钮配置（按所选行业过滤）；失败/空则保留 data 里写死的默认数组（避免空白）
  _loadQuickActions: function () {
    var self = this;
    var ind = getApp().globalData.industry;
    var slug = (ind && ind.slug) || '';
    var base = (ind && ind.apiBase) || ''; // 外部行业把菜单请求指向 app2
    api.quickActions(slug, base).then(function (res) {
      var list = res && res.data;
      if (!list || !list.length) { return; }
      // 给每个主菜单胶囊注入 iconSvg（按 emoji 查对应 SVG）
      list = list.map(function (a) {
        var iconKey = EMOJI_ICON_MAP[a.emoji];
        var svg = iconKey ? (ICONS[iconKey] || '') : '';
        return Object.assign({}, a, { iconSvg: svg });
      });
      self.setData({ quickActions: list });
      // 首次加载：showInChat=true 的按钮作为聊天内联快捷行，由 _greetLoggedIn 在问候语之后推入
      if (!self._initShortcuts) {
        var chatBtns = list.filter(function (a) { return !!a.showInChat; });
        if (chatBtns.length) {
          self._initShortcuts = chatBtns;
          if (self._shortcutsPending) {
            self._shortcutsPending = false;
            self._pushShortcuts(self._initShortcuts);
          }
        }
      }
      wx.nextTick(function () { self._recomputeMsgsHeight(); });
    }).catch(function () { /* 保留默认按钮 */ });
  },

  onReady: function () {
    this._recomputeMsgsHeight();
  },

  // 转发给朋友（右上角菜单 / button open-type="share" 都会触发）
  onShareAppMessage: function () {
    return {
      title: '舌尖香港 · AI 店长助手 🥬',
      path: '/pages/chat/chat',
    };
  },

  // 分享到朋友圈
  onShareTimeline: function () {
    return {
      title: '舌尖香港 · AI 店长助手 🥬',
    };
  },

  _recomputeMsgsHeight: function () {
    var self = this;
    var sys = getWin();
    var total = sys.windowHeight || 600;
    var q = wx.createSelectorQuery().in(self);
    q.select('.header').boundingClientRect();
    q.select('.bottom').boundingClientRect();
    q.exec(function (rects) {
      var headerH = (rects && rects[0] && rects[0].height) || 60;
      var bottomH = (rects && rects[1] && rects[1].height) || 80;
      var next = Math.max(120, Math.floor(total - headerH - bottomH));
      if (next !== self.data.msgsHeight) {
        self.setData({ msgsHeight: next });
        self._scrollDown();
      }
    });
  },

  _greetLoggedIn: function (user) {
    var name = (user && user.name) || '老板';
    var self = this;
    var ind = getApp().globalData.industry || {};
    // 行业欢迎语：后台 industries.greeting 配置；留空用「我是{title}」通用兜底
    var greeting = ind.greeting
      || ('我是 ' + (ind.title || 'AI 助手') + '\n\n点下面菜单或直接在输入框跟我说，我来帮你处理。');
    self._pushAi('嗨，' + name + '！👋 欢迎回来～', 600);
    setTimeout(function () {
      self._pushAi(greeting, 1100);
      // 问候语推完（1100ms 后）再追加快捷行
      setTimeout(function () {
        if (self._initShortcuts) {
          self._pushShortcuts(self._initShortcuts);
        } else {
          self._shortcutsPending = true; // 快捷数据还没到，等 _loadQuickActions 回调补推
        }
      }, 1200);
    }, 1500);
  },

  onFontSize: function (e) {
    var size = e.currentTarget.dataset.size;
    if (size === 'sm' || size === 'md' || size === 'lg') {
      this.setData({ fontSize: size });
    }
  },

  onInput: function (e) {
    this.setData({ chatInput: e.detail.value });
  },

  onQuickAction: function (e) {
    if (this.data.aiBusy) return;
    var key = e.currentTarget.dataset.key || '';
    var action = null;
    var list = this.data.quickActions || [];
    for (var i = 0; i < list.length; i++) {
      if (list[i].key === key) { action = list[i]; break; }
    }
    // shortcuts 类型：有子项则推子项；无子项（如首页）则重推初始快捷行，让导航按钮重新出现在对话底部
    if (action && Array.isArray(action.shortcuts)) {
      this._pushShortcuts(action.shortcuts.length ? action.shortcuts : (this._initShortcuts || []));
      return;
    }
    if (action && action.items && action.items.length) {
      this._openReportMenu(action.items, key);
      return;
    }
    // 返回主页（切换行业）：reLaunch 回落地页，清空页面栈，无需登录
    if (action && action.home) {
      wx.reLaunch({
        url: action.home,
        fail: function () { wx.showToast({ title: '返回失败', icon: 'none' }); },
      });
      return;
    }
    // 带 external 配置：web-view 打开完整外部 URL（如 app2 后台页），不拼 token、无需登录
    if (action && action.external) {
      wx.navigateTo({
        url: '/pages/report/report?url=' + encodeURIComponent(action.external),
        fail: function () { wx.showToast({ title: '打开失败', icon: 'none' }); },
      });
      return;
    }
    // 带 route 配置：直接 navigateTo 小程序原生页（如损耗记录，不走 AI/web-view）
    if (action && action.route) {
      if (!this._requireLogin()) return;
      wx.navigateTo({
        url: action.route,
        fail: function () { wx.showToast({ title: '页面不存在', icon: 'none' }); },
      });
      return;
    }
    // 带 open 配置：直接打开 web-view 页（功能聚合/我的等，不走 AI）
    if (action && action.open) {
      if (!this._requireLogin()) { return; }
      var ou = '/pages/report/report?path=' + encodeURIComponent(action.open.path);
      if (action.open.title) { ou += '&title=' + encodeURIComponent(action.open.title); }
      wx.navigateTo({ url: ou });
      return;
    }
    // 带 externalAuth 配置：打开完整外部 URL（跨域名第三方 SaaS），带上本项目登录 token
    if (action && action.externalAuth) {
      if (!this._requireLogin()) { return; }
      var eu = '/pages/report/report?url=' + encodeURIComponent(action.externalAuth.url) + '&withToken=1';
      if (action.externalAuth.title) { eu += '&title=' + encodeURIComponent(action.externalAuth.title); }
      wx.navigateTo({ url: eu, fail: function () { wx.showToast({ title: '打开失败', icon: 'none' }); } });
      return;
    }
    // 带 web 配置的快捷项：发 AI 文字摘要后，追加一个「打开完整页」按钮打开 web-view
    if (action && action.web) {
      this._sendWithWebLink(action.prompt, action.web);
      return;
    }
    var prompt = e.currentTarget.dataset.prompt || (action && action.prompt) || '';
    if (!prompt) return;
    this.setData({ chatInput: prompt });
    this.onSend();
  },

  // 发送 prompt 拿 AI 文字摘要，成功后追加一个 navigate 卡片按钮打开对应 web-view 页
  _sendWithWebLink: function (prompt, web) {
    var self = this;
    if (!prompt || self.data.aiBusy) return;
    self._pushUser(prompt);
    self.setData({ aiBusy: true, typing: true });
    if (self._serviceRestricted()) return;
    self._scrollDown();
    var app = getApp();
    var ind = app.globalData.industry;
    var wlOpts = { sessionId: self._sessionId };
    if (ind && ind.apiBase) {
      wlOpts.baseOverride = ind.apiBase;
      wlOpts.tokenOverride = ind.apiToken || '';
      wlOpts.pathOverride = ind.aiPath || '';
    }
    api.aiMessage(prompt, wlOpts).then(function (res) {
      self._handleAiResult(res);
      self._pushWebLinkCard(web);
    }).catch(function (err) {
      self._handleAiError(err);
    });
  },

  // 追加一条「打开完整页」链接按钮消息
  _pushWebLinkCard: function (web) {
    var url = '/pages/report/report?path=' + encodeURIComponent(web.path);
    if (web.title) { url += '&title=' + encodeURIComponent(web.title); }
    var msgs = this.data.msgs.concat([{
      id: nextId(),
      from: 'ai',
      weblink: { label: web.label || '打开完整页', url: url },
    }]);
    this.setData({ msgs: msgs });
    this._scrollDown();
  },

  onWebLink: function (e) {
    var url = e.currentTarget.dataset.url;
    if (!url) return;
    if (!this._requireLogin()) return;
    wx.navigateTo({
      url: url,
      fail: function () { wx.showToast({ title: '打开失败', icon: 'none' }); },
    });
  },

  _pushShortcuts: function (shortcuts) {
    var msgs = this.data.msgs;
    if (msgs.length && msgs[msgs.length - 1].from === 'shortcuts') { return; }
    var enriched = shortcuts.map(function (it) {
      var iconKey = EMOJI_ICON_MAP[it.emoji];
      var svg = iconKey ? (ICONS_BLUE[iconKey] || ICONS[iconKey]) : '';
      return Object.assign({}, it, { iconSvg: svg });
    });
    this.setData({ msgs: msgs.concat([{ id: nextId(), from: 'shortcuts', shortcuts: enriched }]) });
    this._scrollDown();
  },

  onShortcutTap: function (e) {
    var item = e.currentTarget.dataset.item || {};
    if (item.route) {
      if (!this._requireLogin()) return;
      wx.navigateTo({ url: item.route, fail: function () { wx.showToast({ title: '页面不存在', icon: 'none' }); } });
      return;
    }
    if (item.external) {
      wx.navigateTo({ url: '/pages/report/report?url=' + encodeURIComponent(item.external), fail: function () { wx.showToast({ title: '打开失败', icon: 'none' }); } });
      return;
    }
    if (item.prompt) {
      this.setData({ chatInput: item.prompt });
      this.onSend();
    }
  },

  _openReportMenu: function (items, key) {
    var self = this;
    var sys = getWin();
    var winW = sys.windowWidth || 375;
    var winH = sys.windowHeight || 667;
    // 弹层目标宽度 (rpx -> px): 360rpx
    var menuW = Math.round(360 * winW / 750);
    var margin = Math.round(16 * winW / 750); // 距屏幕边缘
    var gap = Math.round(16 * winW / 750);    // chip 到弹层的间距

    wx.createSelectorQuery().in(self).select('.qa-chip-' + key).boundingClientRect(function (rect) {
      var anchorCenterX, anchorTop;
      if (rect) {
        anchorCenterX = rect.left + rect.width / 2;
        anchorTop = rect.top;
      } else {
        anchorCenterX = winW / 2;
        anchorTop = winH - 200;
      }
      var left = Math.round(anchorCenterX - menuW / 2);
      if (left < margin) left = margin;
      if (left + menuW > winW - margin) left = winW - margin - menuW;
      var bottom = Math.round(winH - anchorTop + gap);
      var arrowLeft = Math.round(anchorCenterX - left); // 三角形相对 popover 左边
      var enriched = items.map(function (it) {
        var iconKey = EMOJI_ICON_MAP[it.emoji];
        return Object.assign({}, it, { iconSvg: iconKey ? ICONS[iconKey] : '' });
      });
      self.setData({
        reportMenuItems: enriched,
        reportMenuOpen: true,
        reportMenuKey: key,
        reportMenuStyle: 'left:' + left + 'px;bottom:' + bottom + 'px;width:' + menuW + 'px;',
        reportMenuArrowStyle: 'left:' + arrowLeft + 'px;',
      });
    }).exec();
  },

  closeReportMenu: function () {
    if (this.data.reportMenuOpen) this.setData({ reportMenuOpen: false, reportMenuKey: '' });
  },

  // 阻止 popover 内部点击穿透到遮罩
  noop: function () {},

  // 需要登录才能打开的页面：无 token 时显示登录窗口（不跳转，避免报表页闪退）
  // 外部行业检查 apiToken；普通行业检查 paper token。
  _requireLogin: function () {
    var app = getApp();
    var ind = app.globalData && app.globalData.industry;
    if (ind && ind.apiBase) {
      if (ind.apiToken) { return true; }
      wx.showToast({ title: '请联系管理员配置服务账号', icon: 'none' });
      return false;
    }
    if (app.globalData && app.globalData.token) { return true; }
    this.setData({ user: null });
    wx.showToast({ title: '请先登录', icon: 'none' });
    wx.nextTick(this._recomputeMsgsHeight.bind(this));
    return false;
  },

  onReportItem: function (e) {
    var route = e.currentTarget.dataset.route || '';
    var prompt = e.currentTarget.dataset.prompt || '';
    var external = e.currentTarget.dataset.external || '';
    var externalAuth = e.currentTarget.dataset.externalAuth || null;
    this.setData({ reportMenuOpen: false });
    // 带 token 的外部 URL（external_open 类型）
    if (externalAuth && externalAuth.url) {
      if (!this._requireLogin()) return;
      var eu = '/pages/report/report?url=' + encodeURIComponent(externalAuth.url) + '&withToken=1';
      if (externalAuth.title) { eu += '&title=' + encodeURIComponent(externalAuth.title); }
      wx.navigateTo({ url: eu, fail: function () { wx.showToast({ title: '打开失败', icon: 'none' }); } });
      return;
    }
    // 外部 URL（不带 token）：web-view 打开，无需登录
    if (external) {
      wx.navigateTo({
        url: '/pages/report/report?url=' + encodeURIComponent(external),
        fail: function () { wx.showToast({ title: '打开失败', icon: 'none' }); },
      });
      return;
    }
    if (route) {
      if (!this._requireLogin()) return;
      wx.navigateTo({ url: route });
      return;
    }
    if (!prompt || this.data.aiBusy) return;
    this.setData({ chatInput: prompt });
    this.onSend();
  },

  /** AI 卡片按钮 — 根据 intent 分发到不同小程序能力 */
  onCardAction: function (e) {
    var ds = e.currentTarget.dataset;
    var intent = ds.intent || '';
    var payload = ds.payload || {};
    if (typeof payload === 'string') {
      try { payload = JSON.parse(payload); } catch (eP) { payload = {}; }
    }
    var label = ds.label || '按钮';

    if (intent === 'copy' && payload.text) {
      wx.setClipboardData({
        data: String(payload.text),
        success: function () { wx.showToast({ title: '已复制', icon: 'success' }); },
      });
      return;
    }

    if (intent === 'navigate' && payload.url) {
      wx.navigateTo({
        url: String(payload.url),
        fail: function () { wx.showToast({ title: '页面不存在', icon: 'none' }); },
      });
      return;
    }

    if (intent === 'message' && payload.message) {
      this.setData({ chatInput: String(payload.message) });
      this.onSend();
      return;
    }

    // 默认 / 未知 intent：把按钮信息当成新一条用户消息发回 AI，让它接着处理
    var fallback = '我点击了"' + label + '"';
    if (intent) fallback += '（intent: ' + intent + '）';
    if (payload && typeof payload === 'object' && Object.keys(payload).length) {
      try { fallback += '\n附加数据：' + JSON.stringify(payload); } catch (eS) {}
    }
    this.setData({ chatInput: fallback });
    this.onSend();
  },

  // ─── 媒体输入 ─────────────────────────────────────────────────────────────
  togglePlusMenu: function () {
    var self = this;
    self.setData({ plusOpen: !self.data.plusOpen, voiceMode: false });
    wx.nextTick(function () { self._recomputeMsgsHeight(); });
  },

  closePlusMenu: function () {
    var self = this;
    if (self.data.plusOpen) {
      self.setData({ plusOpen: false });
      wx.nextTick(function () { self._recomputeMsgsHeight(); });
    }
  },

  toggleVoiceMode: function () {
    var self = this;
    self.setData({ voiceMode: !self.data.voiceMode, plusOpen: false });
    wx.nextTick(function () { self._recomputeMsgsHeight(); });
  },

  onPickImage: function (e) {
    var self = this;
    if (self.data.aiBusy) return;
    var src = e && e.currentTarget && e.currentTarget.dataset && e.currentTarget.dataset.src;
    self.closePlusMenu();
    var sourceType = src === 'camera' ? ['camera'] : ['album'];
    wx.chooseMedia({
      count: 1,
      mediaType: ['image'],
      sourceType: sourceType,
      success: function (r) {
        var f = r.tempFiles && r.tempFiles[0];
        if (!f) return;
        self._pushMedia({ type: 'image', tempPath: f.tempFilePath });
        self.setData({ aiBusy: true, typing: true });
        self._scrollDown();
        wx.getFileSystemManager().readFile({
          filePath: f.tempFilePath,
          encoding: 'base64',
          success: function (rf) {
            var imgOpts = { imageBase64: rf.data, sessionId: self._sessionId };
            var imgInd = getApp().globalData.industry;
            if (imgInd && imgInd.apiBase) {
              imgOpts.baseOverride = imgInd.apiBase;
              imgOpts.tokenOverride = imgInd.apiToken || '';
              imgOpts.pathOverride = imgInd.aiPath || '';
            }
            api.aiMessage('', imgOpts).then(function (res) {
              self._handleAiResult(res);
            }).catch(function (err) {
              self._handleAiError(err);
            });
          },
          fail: function () {
            self.setData({ aiBusy: false, typing: false });
            self._pushAi('❌ 图片读取失败，请重试。');
          },
        });
      },
      fail: function () { /* user cancelled */ },
    });
  },

  onPickFile: function () {
    var self = this;
    if (self.data.aiBusy) return;
    self.closePlusMenu();
    wx.chooseMessageFile({
      count: 1,
      type: 'file',
      success: function (r) {
        var f = r.tempFiles && r.tempFiles[0];
        if (!f) return;
        self._pushMedia({ type: 'file', tempPath: f.path, name: f.name, size: f.size });
        // 舌尖后端暂无文件解析接口，先提示用户改用文字/图片
        self._pushAi('📄 已收到文件「' + (f.name || '未命名') + '」，不过文件分析功能暂未开放，请改用文字或图片告诉我哦～');
      },
      fail: function () { /* user cancelled */ },
    });
  },

  onVoiceStart: function () {
    var self = this;
    if (self.data.recording) return;
    var mgr = wx.getRecorderManager();
    self._recorder = mgr;
    self._recordStart = Date.now();
    mgr.onError(function (err) {
      wx.showToast({ title: '录音错误：' + ((err && err.errMsg) || ''), icon: 'none' });
      self.setData({ recording: false });
    });
    mgr.onStop(function (res) {
      var dur = Math.round((Date.now() - self._recordStart) / 100) / 10;
      self.setData({ recording: false });
      if (!res || !res.tempFilePath) return;
      if (dur < 0.6) {
        wx.showToast({ title: '说话时间太短', icon: 'none' });
        return;
      }
      self._pushMedia({ type: 'voice', tempPath: res.tempFilePath, duration: dur });
      self.setData({ aiBusy: true, typing: true });
      self._scrollDown();
      if (self._serviceRestricted()) return;
      // 外部行业语音上传走外部后端 /ai/voice
      var vInd = getApp().globalData.industry;
      var vOpts = { sessionId: self._sessionId };
      if (vInd && vInd.apiBase) {
        vOpts.baseOverride = vInd.apiBase;
        vOpts.tokenOverride = vInd.apiToken || '';
      }
      api.aiVoice(res.tempFilePath, vOpts).then(function (data) {
        self._handleAiResult(data);
      }).catch(function (err) {
        self._handleAiError(err);
      });
    });
    mgr.start({
      duration: 60000,
      sampleRate: 16000,
      numberOfChannels: 1,
      encodeBitRate: 48000,
      format: 'mp3',
    });
    self.setData({ recording: true });
  },

  onVoiceEnd: function () {
    if (this._recorder && this.data.recording) {
      this._recorder.stop();
    }
  },

  onPlayVoice: function (e) {
    var url = e.currentTarget.dataset.url || e.currentTarget.dataset.path;
    if (!url) return;
    if (this._audio) { try { this._audio.destroy(); } catch (eD) {} }
    var a = wx.createInnerAudioContext();
    a.src = url;
    a.onError(function () { wx.showToast({ title: '播放失败', icon: 'none' }); });
    a.play();
    this._audio = a;
  },

  onPreviewImage: function (e) {
    var url = e.currentTarget.dataset.url || e.currentTarget.dataset.path;
    if (!url) return;
    wx.previewImage({ current: url, urls: [url] });
  },

  _pushMedia: function (entry) {
    var msg = { id: nextId(), from: 'user' };
    for (var k in entry) { if (entry.hasOwnProperty(k)) msg[k] = entry[k]; }
    var msgs = this.data.msgs.concat([msg]);
    this.setData({ msgs: msgs });
    this._scrollDown();
  },

  onLoginInput: function (e) {
    var field = e.currentTarget.dataset.field;
    if (field !== 'username' && field !== 'password') return;
    var form = {};
    for (var k in this.data.loginForm) {
      if (this.data.loginForm.hasOwnProperty(k)) form[k] = this.data.loginForm[k];
    }
    form[field] = e.detail.value;
    this.setData({ loginForm: form });
  },

  onLogin: function () {
    if (this.data.logging) return;
    var self = this;
    var username = (self.data.loginForm.username || '').trim();
    var password = self.data.loginForm.password || '';
    if (!username || !password) {
      wx.showToast({ title: '请输入账号和密码', icon: 'none' });
      return;
    }
    if (self.data.isRegisterMode) {
      self._doRegister(username, password);
    } else {
      self._doLogin(username, password);
    }
  },

  // 登录/注册表单切换：复用同一组用户名/密码输入框
  onToggleRegisterMode: function () {
    if (this.data.logging) return;
    this.setData({
      isRegisterMode: !this.data.isRegisterMode,
      loginForm: { username: '', password: '' },
    });
  },

  // 实际注册：走 SSO 注册（后端桥接外部 Auth Center 建号），成功即自动登录，跟 _doLogin 收尾一致
  _doRegister: function (username, password) {
    var self = this;
    self.setData({ logging: true });
    wx.nextTick(function () { self._recomputeMsgsHeight(); });

    api.ssoRegister(username, password).then(function () {
      var app = getApp();
      self.setData({
        user: app.globalData.user,
        logging: false,
        isRegisterMode: false,
        loginForm: { username: '', password: '' },
      });
      wx.nextTick(function () { self._recomputeMsgsHeight(); });
      self._greetLoggedIn(app.globalData.user);
      self._loadQuickActions();
    }).catch(function (err) {
      self.setData({ logging: false });
      wx.nextTick(function () { self._recomputeMsgsHeight(); });
      wx.showToast({ title: (err && err.message) || '注册失败', icon: 'none' });
    });
  },

  // 实际登录：走 SSO 单点登录（后端桥接外部 Auth Center）。门店由后端解析，无多门店分支。
  _doLogin: function (identifier, password) {
    var self = this;
    self.setData({ logging: true });
    wx.nextTick(function () { self._recomputeMsgsHeight(); });

    api.ssoLogin(identifier, password).then(function () {
      var app = getApp();
      self.setData({
        user: app.globalData.user,
        logging: false,
        loginForm: { username: '', password: '' },
      });
      wx.nextTick(function () { self._recomputeMsgsHeight(); });
      self._greetLoggedIn(app.globalData.user);
      self._loadQuickActions();
    }).catch(function (err) {
      self.setData({ logging: false });
      wx.nextTick(function () { self._recomputeMsgsHeight(); });
      wx.showToast({ title: (err && err.message) || '登录失败', icon: 'none' });
    });
  },

  // 退出登录：确认后清登录态，回到登录表单
  onLogout: function () {
    var self = this;
    wx.showModal({
      title: '退出登录',
      content: '确定要退出当前账号吗？',
      confirmText: '退出',
      confirmColor: '#E65C46',
      success: function (r) {
        if (!r.confirm) { return; }
        api.logout().then(function () {
          self._sessionId = null;
          self.setData({ user: null, msgs: [], chatInput: '', loginForm: { username: '', password: '' } });
          wx.nextTick(function () { self._recomputeMsgsHeight(); });
        });
      },
    });
  },

  _scrollDown: function () {
    var self = this;
    self.setData({ scrollAnchor: '' });
    setTimeout(function () { self.setData({ scrollAnchor: 'anchor-bottom' }); }, 30);
  },

  _pushUser: function (text) {
    var msgs = this.data.msgs.concat([{ id: nextId(), from: 'user', text: text }]);
    this.setData({ msgs: msgs });
    this._scrollDown();
  },

  _serviceRestricted: function () {
    var ind = getApp().globalData.industry || {};
    if (ind.apiBase) return false;
    if (ind.slug === 'fresh') return false;
    this.setData({ aiBusy: false, typing: false });
    this._pushAi('服务暂未开通，请联系客服开通');
    return true;
  },

  _pushAi: function (text, delay) {
    var self = this;
    delay = delay || 0;
    if (delay > 0) {
      self.setData({ typing: true });
      self._scrollDown();
      setTimeout(function () {
        var msgs = self.data.msgs.concat([{ id: nextId(), from: 'ai', text: text, blocks: mdParse(text) }]);
        self.setData({ msgs: msgs, typing: false });
        self._scrollDown();
      }, delay);
    } else {
      var msgs = self.data.msgs.concat([{ id: nextId(), from: 'ai', text: text, blocks: mdParse(text) }]);
      self.setData({ msgs: msgs });
      self._scrollDown();
    }
  },

  _appendToLastAi: function (text) {
    var msgs = this.data.msgs.slice();
    var last = msgs[msgs.length - 1];
    if (!last || last.from !== 'ai') return;
    var newText = (last.text || '') + text;
    msgs[msgs.length - 1] = { id: last.id, from: 'ai', text: newText, blocks: mdParse(newText) };
    this.setData({ msgs: msgs });
    this._scrollDown();
  },

  // AI 回复成功：渲染 reply 文本并维持会话 id
  _handleAiResult: function (res) {
    this.setData({ typing: false, aiBusy: false });
    if (res && res.session_id) { this._sessionId = res.session_id; }
    // 查询类 intent 的 reply 仅为占位，真实数据在 card_data，优先格式化卡片
    var text = '';
    if (res && res.card_type) {
      text = cardToMarkdown(res.card_type, res.card_data);
    }
    if (!text) {
      text = (res && res.reply ? String(res.reply).trim() : '') || '（空回复）';
    }
    this._pushAi(text);
  },

  // AI 调用失败：登录失效则回到登录态，其它错误内联提示
  _handleAiError: function (err) {
    this.setData({ typing: false, aiBusy: false });
    var msg = (err && err.message) || String(err);
    if (msg === 'App2Unauthenticated') {
      this._sessionId = null;
      this._pushAi('⚠️ 外部服务账号 Token 已失效，请联系管理员在后台更新。');
      this._recomputeMsgsHeight();
      return;
    }
    if (msg === 'Unauthenticated') {
      this.setData({ user: null });
      this._sessionId = null;
      this._pushAi('⚠️ 登录已过期，请在下方重新登录后再聊。');
      this._recomputeMsgsHeight();
      return;
    }
    this._pushAi('❌ AI 暂时不可用：' + msg);
  },

  onSend: function () {
    var self = this;
    var text = (self.data.chatInput || '').trim();
    if (!text || self.data.aiBusy) return;

    self._pushUser(text);
    self.setData({ chatInput: '', aiBusy: true, typing: true });
    self._scrollDown();
    if (self._serviceRestricted()) return;

    var app = getApp();
    var ind = app.globalData.industry;
    var msgOpts = { sessionId: self._sessionId };
    if (ind && ind.apiBase) {
      msgOpts.baseOverride = ind.apiBase;
      msgOpts.tokenOverride = ind.apiToken || '';
      msgOpts.pathOverride = ind.aiPath || '';
    }
    api.aiMessage(text, msgOpts).then(function (res) {
      self._handleAiResult(res);
    }).catch(function (err) {
      self._handleAiError(err);
    });
  },
});
