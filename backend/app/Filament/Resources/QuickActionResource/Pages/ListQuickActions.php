<?php

namespace App\Filament\Resources\QuickActionResource\Pages;

use App\Filament\Resources\QuickActionResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListQuickActions extends ListRecords
{
    protected static string $resource = QuickActionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
