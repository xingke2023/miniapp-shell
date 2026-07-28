<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Industry extends Model
{
    protected $fillable = [
        'slug',
        'name',
        'emoji',
        'title',
        'description',
        'greeting',
        'api_base',
        'api_token',
        'ai_path',
        'ai_media',
        'sort_order',
        'enabled',
    ];

    protected function casts(): array
    {
        return [
            'enabled' => 'boolean',
            'ai_media' => 'boolean',
            'sort_order' => 'integer',
        ];
    }
}
