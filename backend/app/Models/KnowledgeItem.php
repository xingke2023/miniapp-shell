<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class KnowledgeItem extends Model
{
    protected $fillable = ['category_id', 'content', 'is_active', 'sort_order', 'vectorized_at'];

    protected function casts(): array
    {
        return [
            'is_active'     => 'boolean',
            'sort_order'    => 'integer',
            'vectorized_at' => 'datetime',
        ];
    }

    public function scopeVectorized($query): void
    {
        $query->whereNotNull('vectorized_at');
    }

    public function scopeNotVectorized($query): void
    {
        $query->whereNull('vectorized_at');
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(KnowledgeCategory::class, 'category_id');
    }
}
