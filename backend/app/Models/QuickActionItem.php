<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class QuickActionItem extends Model
{
    protected $fillable = [
        'quick_action_id',
        'emoji',
        'label',
        'desc',
        'item_type',
        'route',
        'prompt',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'sort_order' => 'integer',
        ];
    }

    public function quickAction(): BelongsTo
    {
        return $this->belongsTo(QuickAction::class);
    }
}
