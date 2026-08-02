<?php

use App\Http\Controllers\AdminSsoController;
use App\Models\MenuTemplate;
use Illuminate\Support\Facades\Route;

Route::get('/', fn () => redirect('/admin/login'));

// 小程序 JWT 免登录进后台（绕过 web-view 里不稳定的 Livewire 登录表单）
Route::get('/admin/sso', AdminSsoController::class);

// 菜单模版导出（需登录且为管理员）
Route::middleware(['web', 'auth'])->get('/admin/menu-templates/{template}/export', function (MenuTemplate $template) {
    abort_unless(auth()->user()?->is_admin, 403);

    $data = [
        'version'  => 1,
        'name'     => $template->name,
        'industry' => $template->industry,
        'actions'  => $template->quickActions()->with('items')->get()->map(function ($action) {
            return [
                'key'          => $action->key,
                'emoji'        => $action->emoji,
                'label'        => $action->label,
                'badge'        => $action->badge,
                'action_type'  => $action->action_type,
                'prompt'       => $action->prompt,
                'target_path'  => $action->target_path,
                'target_title' => $action->target_title,
                'web_label'    => $action->web_label,
                'admin_only'   => $action->admin_only,
                'enabled'      => $action->enabled,
                'sort_order'   => $action->sort_order,
                'show_in_chat' => $action->show_in_chat,
                'items'        => $action->items->map(fn ($item) => [
                    'emoji'        => $item->emoji,
                    'label'        => $item->label,
                    'desc'         => $item->desc,
                    'item_type'    => $item->item_type,
                    'route'        => $item->route,
                    'prompt'       => $item->prompt,
                    'sort_order'   => $item->sort_order,
                    'show_in_chat' => $item->show_in_chat,
                ])->values()->all(),
            ];
        })->values()->all(),
    ];

    $filename = 'menu-'.str_replace(' ', '-', $template->name).'-'.now()->format('Ymd').'.json';

    return response()->streamDownload(
        fn () => print json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
        $filename,
        ['Content-Type' => 'application/json']
    );
})->name('admin.menu-templates.export');
