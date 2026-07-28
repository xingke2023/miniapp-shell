<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MenuTemplate extends Model
{
    protected $fillable = [
        'industry',
        'name',
        'is_active',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'sort_order' => 'integer',
        ];
    }

    public function quickActions(): HasMany
    {
        return $this->hasMany(QuickAction::class)->orderBy('sort_order')->orderBy('id');
    }
}
