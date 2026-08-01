// utils/request.js
// wx.request 封装：自动注入 Authorization。
// 用 Promise 链而非 async/await，避免触发微信开发者工具的 @babel/runtime 转译路径。

function callBackend(path, options) {
  return new Promise(function (resolve, reject) {
    var app = getApp();
    var token = app.globalData.token || '';
    var headers = Object.assign(
      { 'Content-Type': 'application/json', Accept: 'application/json' },
      token ? { Authorization: 'Bearer ' + token } : {},
      options.header || {}
    );

    wx.request({
      url: app.globalData.apiBaseUrl + path,
      method: options.method || 'GET',
      data: options.data || {},
      header: headers,
      timeout: options.timeout || 60000,
      success: function (res) { resolve(res); },
      fail: function (err) { reject(err); },
    });
  });
}

// 登录成功后把 token/user/storeId 落地到 globalData + storage（login / ssoLogin 共用）。
// 统一存 JWT（无状态）而非 Sanctum opaque token：后端 auth.hybrid 对 JWT 走独立路径，
// 不经会话 guard，避免 web-view 携带 cookie 触发 TransientToken（缺 abilities）500。
function _persistAuth(data) {
  var app = getApp();
  var authToken = data.jwt_token || data.token;
  app.globalData.token = authToken;
  app.globalData.user = data.user;
  app.globalData.storeId = data.store_id;
  // 认证中心原生 accessToken（非本项目自家 jwt_token）：访问认证中心生态内其他服务（如 ai.xingke888.com）要用这个
  // 仅 15 分钟有效，配合 ssoRefreshToken 现用现换（见 refreshSsoToken），不长期依赖这个缓存值
  app.globalData.ssoToken = data.sso_access_token || '';
  app.globalData.ssoRefreshToken = data.sso_refresh_token || '';
  try {
    wx.setStorageSync('token', authToken);
    wx.setStorageSync('user', data.user);
    wx.setStorageSync('storeId', data.store_id);
    wx.setStorageSync('ssoToken', app.globalData.ssoToken);
    wx.setStorageSync('ssoRefreshToken', app.globalData.ssoRefreshToken);
  } catch (e) { /* ignore */ }
  return data;
}

/**
 * 现换一个新鲜的认证中心 accessToken（15分钟有效期，用前现换，效果上等于不用操心过期）。
 * 用 ssoRefreshToken 换新 accessToken；成功后 refreshToken 会轮换，一并存新的。
 * 失败（refreshToken 也失效了）则 reject，调用方回退用旧的缓存 ssoToken 或提示重新登录。
 */
function refreshSsoToken() {
  var app = getApp();
  var refreshToken = app.globalData.ssoRefreshToken || '';
  if (!refreshToken) {
    return Promise.reject(new Error('无 refreshToken'));
  }
  return callBackend('/auth/sso/refresh', {
    method: 'POST',
    data: { refreshToken: refreshToken },
  }).then(function (res) {
    if (res.statusCode === 200 && res.data && res.data.accessToken) {
      app.globalData.ssoToken = res.data.accessToken;
      if (res.data.refreshToken) {
        app.globalData.ssoRefreshToken = res.data.refreshToken;
      }
      try {
        wx.setStorageSync('ssoToken', app.globalData.ssoToken);
        wx.setStorageSync('ssoRefreshToken', app.globalData.ssoRefreshToken);
      } catch (e) { /* ignore */ }
      return app.globalData.ssoToken;
    }
    var msg = (res.data && (res.data.message || res.data.detail)) || ('HTTP ' + res.statusCode);
    throw new Error(msg);
  });
}

/**
 * SSO 单点登录 —— 后端 POST /auth/sso/login（桥接外部 Auth Center）
 * body: { identifier: 用户名或邮箱, password }
 * 后端代理认证中心、映射本地用户后，返回与 /login 同形状的 { token, jwt_token, store_id, user }。
 * 门店在后端解析，无多门店 422 分支。
 */
function ssoLogin(identifier, password) {
  return callBackend('/auth/sso/login', {
    method: 'POST',
    data: { identifier: identifier, password: password },
  }).then(function (res) {
    if (res.statusCode === 200 && res.data && (res.data.jwt_token || res.data.token)) {
      return _persistAuth(res.data);
    }
    var msg = (res.data && (res.data.message || res.data.detail)) || ('HTTP ' + res.statusCode);
    throw new Error(msg);
  });
}

/**
 * SSO 注册 —— 后端 POST /auth/sso/register（桥接外部 Auth Center 建号，成功后自动登录）
 * body: { username, password, name?, email? }
 * username 3~50位字母/数字/下划线，password 至少8位（认证中心自己的要求）
 * 成功返回与 ssoLogin 同形状的 { token, jwt_token, store_id, user }
 */
function ssoRegister(username, password, name, email) {
  var body = { username: username, password: password };
  if (name) { body.name = name; }
  if (email) { body.email = email; }
  return callBackend('/auth/sso/register', {
    method: 'POST',
    data: body,
  }).then(function (res) {
    if (res.statusCode === 200 && res.data && (res.data.jwt_token || res.data.token)) {
      return _persistAuth(res.data);
    }
    var msg = (res.data && (res.data.message || res.data.detail)) || ('HTTP ' + res.statusCode);
    throw new Error(msg);
  });
}

/**
 * 账号密码登录 —— POST /login（保留，供非 SSO 场景复用）
 * body: { login: 用户名或邮箱, password }
 * 成功返回 { token, jwt_token, store_id, user }
 */
function login(username, password, storeId) {
  var body = { login: username, password: password };
  if (storeId) { body.store_id = storeId; }
  return callBackend('/login', {
    method: 'POST',
    data: body,
  }).then(function (res) {
    if (res.statusCode === 200 && res.data && (res.data.jwt_token || res.data.token)) {
      return _persistAuth(res.data);
    }
    // 多门店账号：后端返回 422 + stores 列表 → 抛出带 stores 的错误，由 UI 弹门店选择
    if (res.statusCode === 422 && res.data && res.data.stores && res.data.stores.length) {
      var multiErr = new Error(res.data.message || '该账号属于多个门店，请选择门店');
      multiErr.multiStore = true;
      multiErr.stores = res.data.stores;
      throw multiErr;
    }
    var msg = (res.data && (res.data.message || res.data.detail)) || ('HTTP ' + res.statusCode);
    throw new Error(msg);
  });
}

function clearAuth() {
  var app = getApp();
  app.globalData.token = '';
  app.globalData.user = null;
  app.globalData.storeId = null;
  app.globalData.ssoToken = '';
  app.globalData.ssoRefreshToken = '';
  try {
    wx.removeStorageSync('token');
    wx.removeStorageSync('user');
    wx.removeStorageSync('storeId');
    wx.removeStorageSync('ssoToken');
    wx.removeStorageSync('ssoRefreshToken');
  } catch (e) { /* ignore */ }
}

function request(path, options) {
  options = options || {};
  return callBackend(path, options).then(function (res) {
    if (res.statusCode === 401) {
      clearAuth();
      throw new Error('Unauthenticated');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      var msg = (res.data && (res.data.message || res.data.detail)) || ('HTTP ' + res.statusCode);
      throw new Error(msg);
    }
    return res.data;
  });
}

module.exports = { request: request, login: login, ssoLogin: ssoLogin, ssoRegister: ssoRegister, clearAuth: clearAuth, refreshSsoToken: refreshSsoToken };
