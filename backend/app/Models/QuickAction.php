<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class QuickAction extends Model
{
    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (QuickAction $model): void {
            if (empty($model->key)) {
                $model->key = static::generateUniqueKey($model->label ?? 'action');
            }
        });
    }

    protected static function generateUniqueKey(string $label): string
    {
        $base = Str::slug($label);
        if ($base === '') {
            $base = 'action';
        }

        $key = $base;
        $i = 2;
        while (static::where('key', $key)->exists()) {
            $key = $base . '-' . $i++;
        }

        return $key;
    }
    protected $fillable = [
        'key',
        'emoji',
        'label',
        'badge',
        'action_type',
        'prompt',
        'target_path',
        'target_title',
        'web_label',
        'admin_only',
        'show_in_chat',
        'store_id',
        'industry',
        'menu_template_id',
        'enabled',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'admin_only' => 'boolean',
            'show_in_chat' => 'boolean',
            'enabled' => 'boolean',
            'sort_order' => 'integer',
        ];
    }

    public function items(): HasMany
    {
        return $this->hasMany(QuickActionItem::class)->orderBy('sort_order')->orderBy('id');
    }

    public function store(): BelongsTo
    {
        return $this->belongsTo(Store::class);
    }

    public function menuTemplate(): BelongsTo
    {
        return $this->belongsTo(MenuTemplate::class);
    }

    /**
     * 转成小程序 chat.js 期望的 quickActions 数组项结构。
     * 结构与原写死数组完全一致，小程序拿到即可直接 setData。
     */
    public function toClientArray(): array
    {
        $node = [
            'key' => $this->key,
            'emoji' => $this->emoji ?? '',
            'label' => $this->label,
            'badge' => $this->badge ?? '',
        ];

        if ($this->admin_only) {
            $node['adminOnly'] = true;
        }

        switch ($this->action_type) {
            case 'prompt':
                $node['prompt'] = $this->prompt ?? '';
                break;

            case 'web':
                // 先发 AI 文字摘要，再追加「打开完整页」web-view 链接
                $node['prompt'] = $this->prompt ?? '';
                $node['web'] = [
                    'path' => $this->target_path,
                    'title' => $this->target_title,
                    'label' => $this->web_label,
                ];
                break;

            case 'open':
                // 直接打开 web-view 页（report.js 自动补 ?token=&from=miniapp）
                $node['open'] = [
                    'path' => $this->target_path,
                    'title' => $this->target_title,
                ];
                break;

            case 'external_open':
                // 打开完整外部 URL（跨域名，如第三方 SaaS），report.js 仍自动补 ?token=&from=miniapp
                // 区别于 'external'：'external' 不带 token，这个带
                $node['externalAuth'] = [
                    'url' => $this->target_path,
                    'title' => $this->target_title,
                ];
                break;

            case 'route':
                // 直接 wx.navigateTo 到小程序原生页（区别于 'open' 走 web-view 容器）
                $node['route'] = $this->target_path;
                break;

            case 'external':
                // 用 web-view 打开完整外部 URL（target_path 存整条 URL，不拼 token）；
                // 小程序 chat.js 读 action.external → report.js 的 ?url= 原样加载
                $node['external'] = $this->target_path;
                break;

            case 'home':
                // 返回主页（切换行业）：小程序 chat.js reLaunch 到该路径（清空页面栈，无需登录）
                $node['home'] = $this->target_path ?: '/pages/industry/industry';
                break;

            case 'shortcuts':
                // 展开一排快捷按钮到聊天区（不弹 popover，不跳页）
                $node['shortcuts'] = $this->items->map(function (QuickActionItem $item) {
                    $sub = [
                        'key' => 'qai-'.$item->id,
                        'emoji' => $item->emoji ?? '',
                        'icon' => $item->emoji ?? '',
                        'label' => $item->label,
                    ];
                    if ($item->item_type === 'route') {
                        $sub['route'] = $item->route;
                    } elseif ($item->item_type === 'external') {
                        $sub['external'] = $item->route;
                    } else {
                        $sub['prompt'] = $item->prompt ?? '';
                    }

                    return $sub;
                })->values()->all();
                break;

            case 'menu':
                $node['items'] = $this->items->map(function (QuickActionItem $item) {
                    $sub = [
                        'key' => 'qai-'.$item->id,
                        'emoji' => $item->emoji ?? '',
                        'icon' => $item->emoji ?? '',
                        'label' => $item->label,
                        'desc' => $item->desc ?? '',
                        'showInChat' => (bool) $item->show_in_chat,
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

                    return $sub;
                })->all();
                break;
        }

        return $node;
    }
}
