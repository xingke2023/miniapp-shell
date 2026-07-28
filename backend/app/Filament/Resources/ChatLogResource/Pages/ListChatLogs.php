<?php

namespace App\Filament\Resources\ChatLogResource\Pages;

use App\Filament\Resources\ChatLogResource;
use Filament\Resources\Pages\ListRecords;

class ListChatLogs extends ListRecords
{
    protected static string $resource = ChatLogResource::class;

    protected function getHeaderActions(): array
    {
        return [];
    }
}
