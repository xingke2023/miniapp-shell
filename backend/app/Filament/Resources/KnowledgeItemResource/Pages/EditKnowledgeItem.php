<?php

namespace App\Filament\Resources\KnowledgeItemResource\Pages;

use App\Filament\Resources\KnowledgeItemResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditKnowledgeItem extends EditRecord
{
    protected static string $resource = KnowledgeItemResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
