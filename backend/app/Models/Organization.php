<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Organization extends Model
{
    protected $fillable = [
        'name',
        'code',
        'logo_url',
        'contact_phone',
        'settings',
    ];

    protected function casts(): array
    {
        return [
            'settings' => 'array',
        ];
    }

    public function stores(): HasMany
    {
        return $this->hasMany(Store::class);
    }

    public function products(): HasMany
    {
        return $this->hasMany(Product::class);
    }
}
