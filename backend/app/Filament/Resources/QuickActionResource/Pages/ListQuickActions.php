<?php

namespace App\Filament\Resources\QuickActionResource\Pages;

use App\Filament\Resources\ChatShortcutResource;
use App\Filament\Resources\QuickActionResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListQuickActions extends ListRecords
{
    protected static string $resource = QuickActionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('chat_shortcuts')
                ->label('小程序聊天区胶囊按钮')
                ->icon('heroicon-o-chat-bubble-left-ellipsis')
                ->color('gray')
                ->extraAttributes(['class' => 'shadow-xl'])
                ->url(ChatShortcutResource::getUrl('index')),
            Actions\CreateAction::make(),
        ];
    }
}
