<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class AiSession extends Model
{
    protected $fillable = [
        'store_id',
        'user_id',
        'session_uuid',
        'channel',
        'status',
        'started_at',
        'ended_at',
        'context',
    ];

    protected function casts(): array
    {
        return [
            'context'    => 'array',
            'started_at' => 'datetime',
            'ended_at'   => 'datetime',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (AiSession $session): void {
            if (empty($session->session_uuid)) {
                $session->session_uuid = Str::uuid();
            }
        });
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function store(): BelongsTo
    {
        return $this->belongsTo(Store::class);
    }

    public function messages(): HasMany
    {
        return $this->hasMany(AiMessage::class, 'session_id');
    }
}
