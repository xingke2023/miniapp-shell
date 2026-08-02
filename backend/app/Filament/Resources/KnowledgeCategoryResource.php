<?php

namespace App\Filament\Resources;

use App\Filament\Resources\KnowledgeCategoryResource\Pages;
use App\Models\KnowledgeCategory;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class KnowledgeCategoryResource extends Resource
{
    protected static ?string $model = KnowledgeCategory::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-folder';

    protected static string|\UnitEnum|null $navigationGroup = '企业知识库(AI版)';

    protected static ?string $navigationLabel = '目录管理';

    protected static ?string $modelLabel = '目录';

    protected static ?string $pluralModelLabel = '目录管理';

    protected static ?int $navigationSort = 25;

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\TextInput::make('name')
                ->label('目录名称')
                ->required()
                ->maxLength(100),

            Forms\Components\Select::make('parent_id')
                ->label('上级目录')
                ->options(fn (?KnowledgeCategory $record) => KnowledgeCategory::query()
                    ->when($record?->id, fn ($q) => $q->where('id', '!=', $record->id))
                    ->orderBy('sort_order')
                    ->orderBy('id')
                    ->pluck('name', 'id'))
                ->placeholder('顶级目录（无上级）')
                ->searchable()
                ->nullable(),

            Forms\Components\TextInput::make('sort_order')
                ->label('排序')
                ->integer()
                ->default(0),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('目录名称')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('parent.name')
                    ->label('上级目录')
                    ->badge()
                    ->color('gray')
                    ->placeholder('顶级目录'),

                Tables\Columns\TextColumn::make('items_count')
                    ->label('条目数')
                    ->counts('items')
                    ->badge()
                    ->color('info'),

                Tables\Columns\TextColumn::make('sort_order')
                    ->label('排序')
                    ->sortable(),
            ])
            ->defaultSort('sort_order')
            ->actions([
                Actions\EditAction::make(),
                Actions\DeleteAction::make(),
            ]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListKnowledgeCategories::route('/'),
            'create' => Pages\CreateKnowledgeCategory::route('/create'),
            'edit'   => Pages\EditKnowledgeCategory::route('/{record}/edit'),
        ];
    }
}
