<?php

namespace App\Filament\Resources\UserResource\Pages;

use App\Filament\Resources\UserResource;
use App\Models\User;
use Filament\Actions;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ListRecords;

class ListUsers extends ListRecords
{
    protected static string $resource = UserResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),

            Actions\Action::make('generateMissingApiKeys')
                ->label('为无密钥用户生成 API Key')
                ->icon('heroicon-o-key')
                ->color('warning')
                ->requiresConfirmation()
                ->modalHeading('批量生成 API Key')
                ->modalDescription('将为所有尚未拥有 API Key 的用户自动生成一个，用途描述填写用户姓名。')
                ->action(function (): void {
                    $count = 0;
                    User::query()
                        ->whereDoesntHave('tokens', fn ($q) => $q->where('name', 'like', 'api:%'))
                        ->each(function (User $user) use (&$count): void {
                            $user->createToken('api:'.$user->name);
                            $count++;
                        });

                    Notification::make()
                        ->title("已为 {$count} 位用户生成 API Key")
                        ->success()
                        ->send();
                }),
        ];
    }
}
