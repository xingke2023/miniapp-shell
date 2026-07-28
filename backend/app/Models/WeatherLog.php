<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class WeatherLog extends Model
{
    protected $fillable = [
        'store_id',
        'date',
        'city',
        'weather',
        'temperature_high',
        'temperature_low',
        'humidity',
        'rain_probability',
        'uv_index',
        'description',
    ];

    protected function casts(): array
    {
        return [
            'date' => 'date',
            'temperature_high' => 'integer',
            'temperature_low' => 'integer',
            'humidity' => 'integer',
            'rain_probability' => 'integer',
            'uv_index' => 'integer',
        ];
    }
}
