<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// 每天 23:55 为所有门店所有商品生成每日库存快照
Schedule::command('inventory:generate-snapshots')->dailyAt('23:55');
