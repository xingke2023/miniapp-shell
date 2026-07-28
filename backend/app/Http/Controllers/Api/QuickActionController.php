<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\QuickAction;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class QuickActionController extends Controller
{
    /**
     * 小程序聊天页底部快捷按钮配置（无行业区分，返回所有启用按钮）。
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $storeId = $user?->resolveStoreId();
        $isAdmin = (bool) ($user?->is_admin);

        $actions = QuickAction::query()
            ->with('items')
            ->where('enabled', true)
            // 全门店通用（store_id 为 null）或匹配当前门店
            ->where(function ($q) use ($storeId) {
                $q->whereNull('store_id');
                if ($storeId !== null) {
                    $q->orWhere('store_id', $storeId);
                }
            })
            // 非管理员看不到 admin_only 按钮
            ->when(! $isAdmin, fn ($q) => $q->where('admin_only', false))
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        return response()->json([
            'data' => $actions->map(fn (QuickAction $a) => $a->toClientArray())->all(),
        ]);
    }
}
