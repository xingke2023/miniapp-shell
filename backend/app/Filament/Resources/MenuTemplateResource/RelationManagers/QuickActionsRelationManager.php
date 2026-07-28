<?php

namespace App\Filament\Resources\MenuTemplateResource\RelationManagers;

use Filament\Actions;
use Filament\Forms;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class QuickActionsRelationManager extends RelationManager
{
    protected static string $relationship = 'quickActions';

    protected static ?string $title = '菜单按钮';

    public function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\Select::make('action_type')
                    ->label('按钮类型')
                    ->options([
                        'prompt' => '发送文字给 AI（prompt）',
                        'web' => '发 AI 摘要 + 打开网页（web）',
                        'open' => '直接打开网页（open）',
                        'menu' => '弹出子菜单（menu）',
                        'home' => '返回主页 / 切换行业（home）',
                    ])
                    ->default('prompt')
                    ->required()
                    ->live()
                    ->helperText('menu 类型的子菜单项请到「系统 → 快捷按钮」里编辑'),

                Forms\Components\TextInput::make('emoji')
                    ->label('图标 Emoji')
                    ->maxLength(16)
                    ->placeholder('📊'),

                Forms\Components\TextInput::make('label')
                    ->label('按钮文字')
                    ->required()
                    ->maxLength(50),

                Forms\Components\TextInput::make('key')
                    ->label('标识 key')
                    ->required()
                    ->maxLength(50)
                    ->helperText('英文唯一标识，用作样式类 qa-chip-{key}'),

                Forms\Components\Textarea::make('prompt')
                    ->label('发给 AI 的文字')
                    ->rows(2)
                    ->columnSpanFull()
                    ->visible(fn (Get $get) => in_array($get('action_type'), ['prompt', 'web']))
                    ->required(fn (Get $get) => in_array($get('action_type'), ['prompt', 'web'])),

                Forms\Components\TextInput::make('target_path')
                    ->label('网页路径')
                    ->maxLength(200)
                    ->placeholder('/inventory、/sales-report')
                    ->visible(fn (Get $get) => in_array($get('action_type'), ['web', 'open']))
                    ->required(fn (Get $get) => in_array($get('action_type'), ['web', 'open'])),

                Forms\Components\TextInput::make('target_title')
                    ->label('网页标题')
                    ->maxLength(50)
                    ->visible(fn (Get $get) => in_array($get('action_type'), ['web', 'open'])),

                Forms\Components\TextInput::make('sort_order')
                    ->label('排序（小在前）')
                    ->numeric()
                    ->default(0),

                Forms\Components\Toggle::make('enabled')
                    ->label('启用')
                    ->default(true),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('emoji')->label('图标'),
                Tables\Columns\TextColumn::make('label')->label('按钮文字'),
                Tables\Columns\TextColumn::make('action_type')
                    ->label('类型')
                    ->badge()
                    ->formatStateUsing(fn ($state) => [
                        'prompt' => '文字',
                        'web' => '摘要+网页',
                        'open' => '打开网页',
                        'menu' => '子菜单',
                        'home' => '返回主页',
                    ][$state] ?? $state),
                Tables\Columns\IconColumn::make('enabled')->label('启用')->boolean(),
                Tables\Columns\TextColumn::make('sort_order')->label('排序')->sortable(),
            ])
            ->defaultSort('sort_order')
            ->headerActions([
                Actions\CreateAction::make()
                    ->mutateFormDataUsing(function (array $data): array {
                        $data['industry'] = $this->getOwnerRecord()->industry;

                        return $data;
                    }),
            ])
            ->actions([
                Actions\EditAction::make(),
                Actions\DeleteAction::make(),
            ]);
    }
}
