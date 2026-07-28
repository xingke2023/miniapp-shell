<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ChatShortcutResource\Pages;
use App\Models\QuickAction;
use App\Models\QuickActionItem;
use Filament\Actions;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class ChatShortcutResource extends Resource
{
    protected static ?string $model = QuickActionItem::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-chat-bubble-left-ellipsis';

    protected static string|\UnitEnum|null $navigationGroup = '系统';

    protected static ?string $navigationLabel = '聊天区快捷按钮';

    protected static ?string $modelLabel = '子菜单项';

    protected static ?string $pluralModelLabel = '聊天区快捷按钮';

    protected static ?int $navigationSort = 21;

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('quickAction.label')
                    ->label('所属菜单')
                    ->badge()
                    ->color('gray')
                    ->sortable(),

                Tables\Columns\TextColumn::make('emoji')
                    ->label('图标')
                    ->width('60px'),

                Tables\Columns\TextColumn::make('label')
                    ->label('子项名称')
                    ->searchable(),

                Tables\Columns\TextColumn::make('desc')
                    ->label('说明')
                    ->placeholder('—')
                    ->limit(30),

                Tables\Columns\TextColumn::make('item_type')
                    ->label('行为')
                    ->badge()
                    ->formatStateUsing(fn ($state) => [
                        'prompt'        => '发 AI',
                        'route'         => '小程序页',
                        'external'      => '外链',
                        'external_open' => '外链+token',
                    ][$state] ?? $state)
                    ->color(fn ($state) => match ($state) {
                        'route'         => 'info',
                        'external',
                        'external_open' => 'warning',
                        default         => 'gray',
                    }),

                Tables\Columns\ToggleColumn::make('show_in_chat')
                    ->label('显示在聊天区'),

                Tables\Columns\TextColumn::make('sort_order')
                    ->label('排序')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('quick_action_id')
                    ->label('所属菜单')
                    ->options(fn () => QuickAction::where('action_type', 'menu')
                        ->orderBy('sort_order')
                        ->pluck('label', 'id')),

                Tables\Filters\TernaryFilter::make('show_in_chat')
                    ->label('聊天区显示')
                    ->trueLabel('已勾选')
                    ->falseLabel('未勾选'),
            ])
            ->actions([
                Actions\EditAction::make(),
            ])
            ->defaultSort('quick_action_id')
            ->paginated(false);
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListChatShortcuts::route('/'),
            'edit'  => Pages\EditChatShortcut::route('/{record}/edit'),
        ];
    }
}
