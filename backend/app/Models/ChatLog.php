<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChatLog extends Model
{
    protected $fillable = [
        'agent_id',
        'direction',
        'channel',
        'account_id',
        'conversation_id',
        'message_id',
        'sender',
        'content',
        'success',
        'error_msg',
        'session_key',
        'occurred_at',
    ];

    protected function casts(): array
    {
        return [
            'occurred_at' => 'datetime',
            'success' => 'boolean',
        ];
    }
}
