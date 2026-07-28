<?php

namespace App\Filament\Resources\MenuTemplateResource\Pages;

use App\Filament\Resources\MenuTemplateResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditMenuTemplate extends EditRecord
{
    protected static string $resource = MenuTemplateResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
