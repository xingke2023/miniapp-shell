<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Industry;
use Illuminate\Http\JsonResponse;

class IndustryController extends Controller
{
    /**
     * 公开的行业列表（小程序启动「选择行业」页）。
     * 无需鉴权——选行业先于登录。
     * 返回 { data: [ { slug, name, emoji, title, description }, ... ] }
     */
    public function index(): JsonResponse
    {
        $rows = Industry::query()
            ->where('enabled', true)
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get(['slug', 'name', 'emoji', 'title', 'description', 'greeting', 'api_base', 'api_token', 'ai_path', 'ai_media']);

        return response()->json(['data' => $rows]);
    }
}
