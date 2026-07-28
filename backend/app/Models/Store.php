<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Store extends Model
{
    protected $fillable = [
        'organization_id',
        'region_id',
        'name',
        'code',
        'address',
        'status',
    ];

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function inventory(): HasMany
    {
        return $this->hasMany(Inventory::class);
    }
}
