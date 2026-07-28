// utils/api.js
// 全部使用 ES5 风格（function + var，无解构 / 无默认参数 / 无箭头函数），
// 避免微信开发者工具的 ES6→ES5 转译触发 @babel/runtime helper require。

var req = require('./request.js');
var request = req.request;
var login = req.login;
var ssoLogin = req.ssoLogin;
var ssoRegister = req.ssoRegister;
var clearAuth = req.clearAuth;
var refreshSsoToken = req.refreshSsoToken;

/**
 * 文字 / 图片 AI 消息 —— POST /ai/message
 * @param {string} text  用户文字（图片识别时可传空字符串）
 * @param {object} opts  { imageBase64?, sessionId?, baseOverride?, tokenOverride?, pathOverride? }
 * @returns {Promise<object>} { reply, intent, card_type?, card_data?, session_id }
 */
function aiMessage(text, opts) {
  opts = opts || {};
  var path = opts.pathOverride || '/ai/message';
  return request(path, {
    method: 'POST',
    data: {
      text: text || '',
      image_base64: opts.imageBase64 || undefined,
      session_id: opts.sessionId || undefined,
    },
    timeout: 90000,
    baseOverride: opts.baseOverride || undefined,
    tokenOverride: opts.tokenOverride !== undefined ? opts.tokenOverride : undefined,
  });
}

/**
 * 语音 AI 消息 —— POST /ai/voice（multipart，字段名 audio）
 * @param {string} filePath  录音临时文件路径（mp3）
 * @param {object|number} [opts]  { sessionId?, baseOverride?, tokenOverride? }
 * @returns {Promise<object>} { reply, intent, session_id, ... }
 */
function aiVoice(filePath, opts) {
  if (typeof opts === 'number' || typeof opts === 'string') {
    opts = { sessionId: opts };
  }
  opts = opts || {};
  return new Promise(function (resolve, reject) {
    var app = getApp();
    var external = !!opts.baseOverride;
    var base = opts.baseOverride || app.globalData.apiBaseUrl;
    var token = external
      ? (opts.tokenOverride || '')
      : (app.globalData.token || '');
    if (!external && !token) { reject(new Error('Unauthenticated')); return; }
    var formData = {};
    if (opts.sessionId) { formData.session_id = opts.sessionId; }
    var header = { Accept: 'application/json' };
    if (token) { header.Authorization = 'Bearer ' + token; }
    wx.uploadFile({
      url: base + '/ai/voice',
      filePath: filePath,
      name: 'audio',
      header: header,
      formData: formData,
      timeout: 120000,
      success: function (res) {
        if (res.statusCode === 401) { reject(new Error('Unauthenticated')); return; }
        var data = null;
        try { data = JSON.parse(res.data); } catch (e) { /* ignore */ }
        if (res.statusCode < 200 || res.statusCode >= 300) {
          var msg = (data && (data.message || data.reply)) || ('HTTP ' + res.statusCode);
          reject(new Error(msg));
          return;
        }
        if (!data) { reject(new Error('语音响应解析失败')); return; }
        resolve(data);
      },
      fail: function (err) {
        reject(new Error(err && err.errMsg ? err.errMsg : '语音上传失败'));
      },
    });
  });
}

// 校验当前 token 是否有效
function me() {
  return request('/me', { method: 'GET', timeout: 15000 });
}

// 聊天页底部快捷按钮配置（后台可配）
function quickActions() {
  return request('/quick-actions', { method: 'GET', timeout: 15000 });
}

// 公开行业列表（无需登录）
function industries() {
  return request('/industries', { method: 'GET', timeout: 15000 });
}

// 公开应用配置（标题等品牌文案，无需登录）
function appConfig() {
  return request('/app-config', { method: 'GET', timeout: 15000 });
}

// 退出登录
function logout() {
  return request('/logout', { method: 'POST', timeout: 10000 })
    .catch(function () { /* 忽略网络/401 错误 */ })
    .then(function () { clearAuth(); });
}

module.exports = {
  login: login,
  ssoLogin: ssoLogin,
  ssoRegister: ssoRegister,
  refreshSsoToken: refreshSsoToken,
  me: me,
  logout: logout,
  quickActions: quickActions,
  industries: industries,
  appConfig: appConfig,
  aiMessage: aiMessage,
  aiVoice: aiVoice,
};
