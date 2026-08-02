<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ChatShortcutResource\Pages;
use App\Models\QuickAction;
use App\Models\QuickActionItem;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class ChatShortcutResource extends Resource
{
    protected static ?string $model = QuickActionItem::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-chat-bubble-left-ellipsis';

    protected static string|\UnitEnum|null $navigationGroup = '前端系统';

    protected static ?string $navigationLabel = '小程序聊天区胶囊按钮';

    protected static ?string $modelLabel = '子菜单项';

    protected static ?string $pluralModelLabel = '小程序聊天区胶囊按钮';

    protected static ?int $navigationSort = 21;

    protected static bool $shouldRegisterNavigation = false;

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
                    ->html()
                    ->formatStateUsing(function (?string $state): string {
                        if (! $state) {
                            return '<span class="text-gray-400">—</span>';
                        }
                        if (preg_match('/^[a-z0-9-]+$/', $state)) {
                            return svg('heroicon-o-'.$state, ['class' => 'w-5 h-5 inline-block text-gray-600 dark:text-gray-300'])->toHtml();
                        }

                        return e($state);
                    })
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
        return $schema->schema([
            Forms\Components\TextInput::make('label')
                ->label('标题')
                ->required()
                ->maxLength(50),
            Forms\Components\TextInput::make('desc')
                ->label('副标题说明')
                ->maxLength(100),
            Forms\Components\Select::make('item_type')
                ->label('点击行为')
                ->options([
                    'prompt'        => '发送文字给 AI',
                    'route'         => '打开小程序页',
                    'external'      => '打开外部链接（不带 token）',
                    'external_open' => '打开外部链接（带登录 token）',
                ])
                ->default('prompt')
                ->required()
                ->live(),
            Forms\Components\Textarea::make('prompt')
                ->label('发给 AI 的文字')
                ->rows(2)
                ->columnSpanFull()
                ->visible(fn (Get $get) => $get('item_type') === 'prompt')
                ->required(fn (Get $get) => $get('item_type') === 'prompt'),
            Forms\Components\TextInput::make('route')
                ->label('路径 / URL')
                ->maxLength(500)
                ->placeholder('/pages/report/report 或 https://example.com')
                ->visible(fn (Get $get) => in_array($get('item_type'), ['route', 'external', 'external_open']))
                ->required(fn (Get $get) => in_array($get('item_type'), ['route', 'external', 'external_open'])),
            Forms\Components\Toggle::make('show_in_chat')
                ->label('显示在聊天区（蓝色胶囊）')
                ->default(true),
            Forms\Components\TextInput::make('sort_order')
                ->label('排序（小在前）')
                ->numeric()
                ->default(0),
        ]);
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
