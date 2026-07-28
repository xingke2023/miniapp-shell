<?php

namespace App\Filament\Resources\MenuTemplateResource\Pages;

use App\Filament\Resources\MenuTemplateResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListMenuTemplates extends ListRecords
{
    protected static string $resource = MenuTemplateResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
