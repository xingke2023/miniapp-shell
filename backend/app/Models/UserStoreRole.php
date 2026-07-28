<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserStoreRole extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'store_id',
        'region_id',
        'role_id',
        'granted_by',
        'granted_at',
        'expired_at',
    ];

    protected function casts(): array
    {
        return [
            'granted_at' => 'datetime',
            'expired_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function store(): BelongsTo
    {
        return $this->belongsTo(Store::class);
    }

    public function role(): BelongsTo
    {
        return $this->belongsTo(Role::class);
    }

    public function grantedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'granted_by');
    }
}
