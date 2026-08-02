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
     * 小程序聊天页底部快捷按钮配置（无行业区分，返回所有启用按钮）。
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $storeId = $user?->resolveStoreId();
        $isAdmin = (bool) ($user?->is_admin);

        // 优先用用户指定的模版，否则取行业当前生效模版
        $templateId = $user?->menu_template_id
            ?? MenuTemplate::query()->where('is_active', true)->value('id');

        $actions = QuickAction::query()
            ->with('items')
            ->where('enabled', true)
            ->where('key', '!=', 'home')
            ->when($templateId, fn ($q) => $q->where('menu_template_id', $templateId))
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

        // 首页按钮固定在第一位，不由数据库控制
        $homeNode = ['key' => 'home', 'emoji' => '🏠', 'label' => '首页', 'badge' => ''];
        $data = array_merge([$homeNode], $actions->map(fn (QuickAction $a) => $a->toClientArray())->all());

        // 聊天区蓝色胶囊：收集所有 menu 类型按钮下 show_in_chat=true 的子项
        $shortcuts = [];
        foreach ($actions as $action) {
            if ($action->action_type !== 'menu') {
                continue;
            }
            foreach ($action->items as $item) {
                if (! $item->show_in_chat) {
                    continue;
                }
                $sub = [
                    'key' => 'qai-'.$item->id,
                    'emoji' => $item->emoji ?? '',
                    'label' => $item->label,
                ];
                if ($item->item_type === 'route') {
                    $sub['route'] = $item->route;
                } elseif ($item->item_type === 'external') {
                    $sub['external'] = $item->route;
                } elseif ($item->item_type === 'external_open') {
                    $sub['externalAuth'] = ['url' => $item->route, 'title' => $item->label];
                } else {
                    $sub['prompt'] = $item->prompt ?? '';
                }
                $shortcuts[] = $sub;
            }
        }

        return response()->json([
            'data' => $data,
            'shortcuts' => $shortcuts,
        ]);
    }
}
