<?php

namespace App\Models;

use App\Models\AppSetting;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MenuTemplate extends Model
{
    protected $fillable = [
        'industry',
        'name',
        'is_active',
        'sort_order',
        'settings',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'sort_order' => 'integer',
            'settings' => 'array',
        ];
    }

    /** 读取模板专属设置，不存在时回退全局 AppSetting。 */
    public function getSetting(string $key, ?string $default = null): ?string
    {
        $value = ($this->settings[$key] ?? null);

        if ($value !== null && $value !== '') {
            return (string) $value;
        }

        return AppSetting::get($key, $default);
    }

    public function quickActions(): HasMany
    {
        return $this->hasMany(QuickAction::class)->orderBy('sort_order')->orderBy('id');
    }
}
