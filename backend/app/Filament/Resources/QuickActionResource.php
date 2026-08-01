<?php

namespace App\Filament\Resources;

use App\Filament\Resources\QuickActionResource\Pages;
use App\Filament\Resources\QuickActionResource\RelationManagers\ItemsRelationManager;
use App\Models\QuickAction;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class QuickActionResource extends Resource
{
    protected static ?string $model = QuickAction::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-squares-2x2';

    protected static string|\UnitEnum|null $navigationGroup = '系统';

    protected static ?string $navigationLabel = '小程序菜单';

    protected static ?string $modelLabel = '快捷菜单';

    protected static ?string $pluralModelLabel = '小程序菜单';

    protected static ?int $navigationSort = 21;

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('label')
                    ->label('按钮文字')
                    ->required()
                    ->maxLength(50),

                Forms\Components\Select::make('action_type')
                    ->label('按钮类型')
                    ->options([
                        'prompt'        => '发文字给 AI',
                        'web'           => 'AI 摘要 + 打开网页',
                        'open'          => '打开网页（带 token）',
                        'external_open' => '打开外部网站（带 token）',
                        'menu'          => '弹出子菜单',
                        'shortcuts'     => '展开快捷按钮到聊天区',
                        'home'          => '返回首页（reLaunch）',
                        'route'         => '跳转小程序原生页',
                        'external'      => '打开外部网站（不带 token）',
                    ])
                    ->default('prompt')
                    ->required()
                    ->live()
                    ->helperText('选 menu 或 shortcuts 后，在下方「子菜单项」维护'),

                Forms\Components\Textarea::make('prompt')
                    ->label('发给 AI 的文字')
                    ->rows(2)
                    ->columnSpanFull()
                    ->visible(fn (Get $get) => in_array($get('action_type'), ['prompt', 'web']))
                    ->required(fn (Get $get) => in_array($get('action_type'), ['prompt', 'web'])),

                Forms\Components\TextInput::make('target_path')
                    ->label('路径 / 网址')
                    ->maxLength(200)
                    ->placeholder('/pages/chat/chat 或 https://example.com')
                    ->helperText('home: 小程序页路径；open/external_open: web-view 地址（自动带 token）；external: 外部 URL（不带 token）')
                    ->visible(fn (Get $get) => in_array($get('action_type'), ['web', 'open', 'external_open', 'home', 'route', 'external']))
                    ->required(fn (Get $get) => in_array($get('action_type'), ['web', 'open', 'external_open', 'route', 'external'])),

                Forms\Components\TextInput::make('target_title')
                    ->label('网页标题')
                    ->maxLength(50)
                    ->visible(fn (Get $get) => in_array($get('action_type'), ['web', 'open', 'external_open'])),

                Forms\Components\TextInput::make('web_label')
                    ->label('「打开完整页」按钮文字')
                    ->maxLength(50)
                    ->placeholder('📦 打开完整库存页')
                    ->visible(fn (Get $get) => $get('action_type') === 'web'),

                Forms\Components\TextInput::make('badge')
                    ->label('角标文字')
                    ->maxLength(20)
                    ->helperText('留空不显示角标'),

                Forms\Components\TextInput::make('sort_order')
                    ->label('排序（小在前）')
                    ->numeric()
                    ->default(0),

                Forms\Components\Toggle::make('enabled')
                    ->label('启用')
                    ->default(true),

                Forms\Components\Toggle::make('admin_only')
                    ->label('仅管理员可见'),

            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('sort_order')->label('序')->sortable(),
                Tables\Columns\TextColumn::make('label')->label('按钮文字')->searchable(),
                Tables\Columns\TextColumn::make('action_type')
                    ->label('类型')
                    ->badge()
                    ->formatStateUsing(fn ($state) => [
                        'prompt'        => '发给 AI',
                        'web'           => 'AI+网页',
                        'open'          => '打开网页',
                        'external_open' => '外部网站',
                        'menu'          => '子菜单',
                        'shortcuts'     => '快捷行',
                        'home'          => '返回首页',
                        'route'         => '原生页',
                        'external'      => '外链',
                    ][$state] ?? $state)
                    ->color(fn ($state) => match ($state) {
                        'menu', 'shortcuts' => 'warning',
                        'open', 'external_open', 'external' => 'info',
                        'web' => 'success',
                        'home' => 'danger',
                        default => 'gray',
                    }),
                Tables\Columns\IconColumn::make('admin_only')->label('仅管理员')->boolean(),
                Tables\Columns\IconColumn::make('enabled')->label('启用')->boolean(),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('enabled')->label('启用'),
                Tables\Filters\TernaryFilter::make('admin_only')->label('仅管理员'),
            ])
            ->actions([
                Actions\EditAction::make(),
                Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Actions\BulkActionGroup::make([
                    Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('sort_order');
    }

    public static function getRelations(): array
    {
        return [
            ItemsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListQuickActions::route('/'),
            'create' => Pages\CreateQuickAction::route('/create'),
            'edit' => Pages\EditQuickAction::route('/{record}/edit'),
        ];
    }
}
