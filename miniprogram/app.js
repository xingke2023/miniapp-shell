// app.js
App({
  globalData: {
    apiBaseUrl: 'https://app53.xingke888.com/api',
    token: '',
    // 认证中心原生 accessToken：访问认证中心生态内其他服务（如 ai.xingke888.com 公众号写作）要用这个，不是上面的本项目 token
    ssoToken: '',
    ssoRefreshToken: '',
    user: null,
    storeId: null,
    // 当前会话所选行业 {slug, title, apiBase, apiToken}；仅内存、不写 storage —— 每次进入都重新选行业
    industry: null,
  },

  onLaunch: function () {
    try {
      var token = wx.getStorageSync('token') || '';
      // 没有 token 一律视为未登录：不恢复可能残留的 user/storeId，
      // 否则聊天页会"假登录"（显示已登录但 token 为空，导致报表/AI 页闪退）。
      this.globalData.token = token;
      this.globalData.user = token ? (wx.getStorageSync('user') || null) : null;
      this.globalData.storeId = token ? (wx.getStorageSync('storeId') || null) : null;
      this.globalData.ssoToken = token ? (wx.getStorageSync('ssoToken') || '') : '';
      this.globalData.ssoRefreshToken = token ? (wx.getStorageSync('ssoRefreshToken') || '') : '';
      if (!token) {
        try {
          wx.removeStorageSync('user');
          wx.removeStorageSync('storeId');
          wx.removeStorageSync('ssoToken');
          wx.removeStorageSync('ssoRefreshToken');
        } catch (e2) { /* ignore */ }
      }
    } catch (e) {
      this.globalData.token = '';
      this.globalData.user = null;
      this.globalData.storeId = null;
      this.globalData.ssoToken = '';
      this.globalData.ssoRefreshToken = '';
    }
  },
});
