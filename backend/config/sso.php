<?php

return [

    /*
    |--------------------------------------------------------------------------
    | SSO 单点登录（外部 Auth Center）
    |--------------------------------------------------------------------------
    |
    | 小程序登录走桥接：账号密码交给后端 → 后端代理 Auth Center 登录、验签外部
    | accessToken（HS256，secret = sso.jwt_secret）→ 映射/创建本地用户 →
    | 签发本项目自家 JWT 返回。Auth Center 的响应为 {success, data|error} 信封。
    |
    */

    'base_url' => env('SSO_AUTH_BASE_URL', 'https://mo.xingke888.com/api'),

    'jwt_secret' => env('SSO_JWT_SECRET'),

    'algo' => 'HS256',

    'timeout' => (int) env('SSO_TIMEOUT', 15),

];
