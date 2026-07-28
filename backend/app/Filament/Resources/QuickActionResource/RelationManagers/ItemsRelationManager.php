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
                        'prompt' => '发送文字给 AI',
                        'route' => '打开小程序页',
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
                    ->label('小程序页路径')
                    ->maxLength(200)
                    ->placeholder('/pages/report/report')
                    ->visible(fn (Get $get) => $get('item_type') === 'route')
                    ->required(fn (Get $get) => $get('item_type') === 'route'),
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
                Tables\Columns\TextColumn::make('item_type')
                    ->label('行为')
                    ->badge()
                    ->formatStateUsing(fn ($state) => $state === 'route' ? '打开页' : '发 AI')
                    ->color(fn ($state) => $state === 'route' ? 'info' : 'gray'),
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
