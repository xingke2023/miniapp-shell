<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use Illuminate\Http\JsonResponse;

class AppConfigController extends Controller
{
    /**
     * 公开的应用配置（小程序标题等品牌文案）。
     * 无需鉴权——登录前的页面（如登录表单顶栏）也要能拿到标题。
     * 返回 { data: { key: value, ... } }
     */
    public function index(): JsonResponse
    {
        $map = AppSetting::query()
            ->orderBy('sort_order')
            ->pluck('value', 'key');

        return response()->json(['data' => $map]);
    }
}
