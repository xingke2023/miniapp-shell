// pages/report/report.js
// 通用 web-view 容器：按 path 参数加载前端任意页面，并把小程序登录 token 通过 ?token= 传过去。
// 用法：wx.navigateTo({ url: '/pages/report/report?path=%2Finventory&title=今日库存' })
var api = require('../../utils/api.js');
var WEB_ORIGIN = 'https://app51.xingke888.com';
var DEFAULT_PATH = '/sales-report';

Page({
  data: {
    url: '',
  },

  onLoad: function (options) {
    options = options || {};

    if (options.title) {
      wx.setNavigationBarTitle({ title: decodeURIComponent(options.title) });
    }

    // url 参数：完整外部 URL（如 app2 后台页、认证中心生态内其他服务）。
    // withToken=1 时补认证中心原生 accessToken（ssoToken，不是本项目自家 token）——
    // 生态内其他服务认的是认证中心签的 token，不认本项目自己重签的 jwt_token。否则原样加载、不要求登录。
    if (options.url) {
      var self = this;
      var rawUrl = decodeURIComponent(options.url);
      if (options.withToken === '1') {
        var appForToken = getApp();
        var cachedSsoToken = (appForToken.globalData && appForToken.globalData.ssoToken) || '';
        // accessToken 仅 15 分钟有效：每次打开都现换一个新鲜的，避免缓存的那个已过期；
        // 换失败（如 refreshToken 也失效）就退回缓存的旧值兜底，两者都没有才提示重新登录
        api.refreshSsoToken().catch(function () {
          return cachedSsoToken;
        }).then(function (freshToken) {
          var ssoToken = freshToken || cachedSsoToken;
          if (!ssoToken) {
            wx.showToast({ title: '请先登录', icon: 'none' });
            setTimeout(function () { wx.navigateBack(); }, 600);
            return;
          }
          // 认证中心生态内的外部服务约定用 accessToken= 这个参数名（不是本项目内部页面用的 token=）
          var sep = rawUrl.indexOf('?') === -1 ? '?' : '&';
          self.setData({ url: rawUrl + sep + 'accessToken=' + encodeURIComponent(ssoToken) });
        });
        return;
      }
      this.setData({ url: rawUrl });
      return;
    }

    var path = options.path ? decodeURIComponent(options.path) : DEFAULT_PATH;
    if (path.charAt(0) !== '/') { path = '/' + path; }

    var app = getApp();
    // 外部行业用该行业的 apiToken + apiBase 域名；普通行业用 paper token
    var ind = app.globalData && app.globalData.industry;
    var isExternal = !!(ind && ind.apiBase);
    var token, webOrigin;
    if (isExternal) {
      token = (ind && ind.apiToken) || '';
      // apiBase 是 https://app2.xingke888.com/api，webOrigin 去掉 /api
      webOrigin = ind.apiBase.replace(/\/api\/?$/, '');
    } else {
      token = (app.globalData && app.globalData.token) || '';
      webOrigin = WEB_ORIGIN;
    }
    // 没有 token 不加载网页：退回聊天页
    if (!token) {
      wx.showToast({ title: '请先登录', icon: 'none' });
      setTimeout(function () { wx.navigateBack(); }, 600);
      return;
    }
    // _t=时间戳：防止微信 web-view 缓存旧 HTML（旧 HTML 引用旧 JS bundle → 404 → 页面卡「加载中」）
    this.setData({
      url: webOrigin + path + '?token=' + encodeURIComponent(token) + '&from=miniapp&_t=' + Date.now(),
    });
  },
});
