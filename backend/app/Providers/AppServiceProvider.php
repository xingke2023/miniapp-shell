<?php

namespace App\Providers;

use App\Models\KnowledgeItem;
use App\Observers\KnowledgeItemObserver;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void {}

    public function boot(): void
    {
        KnowledgeItem::observe(KnowledgeItemObserver::class);
    }
}
