<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MenuTemplate;
use App\Models\QuickAction;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class QuickActionController extends Controller
{
    /**
     * 小程序聊天页底部快捷按钮配置。
     * 按当前用户的门店 + 是否管理员过滤，返回组装好的按钮树（结构同原写死数组）。
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $storeId = $user?->resolveStoreId();
        $isAdmin = (bool) ($user?->is_admin);
        // 小程序「选择行业」后带的 slug：取该行业「当前生效模版」的按钮 + 全行业通用按钮
        $industry = $request->query('industry');
        $activeTemplateId = $industry
            ? MenuTemplate::query()
                ->where('industry', $industry)
                ->where('is_active', true)
                ->value('id')
            : null;

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
            // 通用按钮（不绑模版且不绑行业）或当前生效模版下的按钮
            ->where(function ($q) use ($activeTemplateId) {
                $q->where(function ($u) {
                    $u->whereNull('menu_template_id')->whereNull('industry');
                });
                if ($activeTemplateId) {
                    $q->orWhere('menu_template_id', $activeTemplateId);
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
