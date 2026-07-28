<?php

namespace App\Filament\Resources\QuickActionResource\RelationManagers;

use Filament\Forms;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class ItemsRelationManager extends RelationManager
{
    protected static string $relationship = 'items';

    protected static ?string $title = '子菜单项';

    public function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('emoji')
                    ->label('图标 Emoji')
                    ->maxLength(16)
                    ->placeholder('📊'),
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
                    ->helperText('route: 小程序页路径；external/external_open: 完整 URL')
                    ->visible(fn (Get $get) => in_array($get('item_type'), ['route', 'external', 'external_open']))
                    ->required(fn (Get $get) => in_array($get('item_type'), ['route', 'external', 'external_open'])),
                Forms\Components\Toggle::make('show_in_chat')
                    ->label('显示在聊天区（蓝色胶囊）')
                    ->helperText('勾选后，登录问候语下方会出现此子项按钮')
                    ->default(true),
                Forms\Components\TextInput::make('sort_order')
                    ->label('排序（小在前）')
                    ->numeric()
                    ->default(0),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('emoji')->label('图标'),
                Tables\Columns\TextColumn::make('label')->label('标题'),
                Tables\Columns\TextColumn::make('desc')->label('说明')->placeholder('—'),
                Tables\Columns\TextColumn::make('route')
                    ->label('路径 / URL')
                    ->limit(40)
                    ->placeholder('—'),
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
                        'route' => 'info',
                        'external', 'external_open' => 'warning',
                        default => 'gray',
                    }),
                Tables\Columns\IconColumn::make('show_in_chat')
                    ->label('聊天区显示')
                    ->boolean(),
                Tables\Columns\TextColumn::make('sort_order')->label('排序')->sortable(),
            ])
            ->defaultSort('sort_order')
            ->headerActions([
                Actions\CreateAction::make(),
            ])
            ->actions([
                Actions\EditAction::make(),
                Actions\DeleteAction::make(),
            ]);
    }
}
