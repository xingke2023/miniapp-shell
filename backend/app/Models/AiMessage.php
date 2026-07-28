<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AiMessage extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'session_id',
        'role',
        'input_type',
        'raw_content',
        'voice_url',
        'image_urls',
        'transcribed_text',
        'ocr_text',
        'ai_response',
        'intent',
        'entities',
        'confidence',
        'dispatched_module',
        'dispatched_action_id',
        'processing_time_ms',
        'created_at',
    ];

    protected function casts(): array
    {
        return [
            'image_urls' => 'array',
            'entities'   => 'array',
            'confidence' => 'decimal:4',
            'created_at' => 'datetime',
        ];
    }

    public function session(): BelongsTo
    {
        return $this->belongsTo(AiSession::class, 'session_id');
    }
}
