<?php

namespace App\Filament\Resources;

use App\Filament\Resources\KnowledgeItemResource\Pages;
use App\Models\KnowledgeCategory;
use App\Models\KnowledgeItem;
use App\Services\EmbeddingService;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;

class KnowledgeItemResource extends Resource
{
    protected static ?string $model = KnowledgeItem::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-document-text';

    protected static string|\UnitEnum|null $navigationGroup = '企业知识库(AI版)';

    protected static ?string $navigationLabel = '知识条目';

    protected static ?string $modelLabel = '知识条目';

    protected static ?string $pluralModelLabel = '知识条目';

    protected static ?int $navigationSort = 26;

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\Select::make('category_id')
                ->label('所属目录')
                ->options(fn () => KnowledgeCategory::query()
                    ->orderBy('sort_order')
                    ->orderBy('id')
                    ->pluck('name', 'id'))
                ->searchable()
                ->nullable()
                ->placeholder('未分类'),

            Forms\Components\Textarea::make('content')
                ->label('内容')
                ->required()
                ->rows(10)
                ->columnSpanFull(),

            Forms\Components\Toggle::make('is_active')
                ->label('启用')
                ->default(true),

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
                Tables\Columns\TextColumn::make('category.name')
                    ->label('目录')
                    ->badge()
                    ->color('primary')
                    ->placeholder('未分类'),

                Tables\Columns\TextColumn::make('content')
                    ->label('内容预览')
                    ->searchable()
                    ->limit(80)
                    ->placeholder('—'),

                Tables\Columns\IconColumn::make('vectorized_at')
                    ->label('向量化')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-circle')
                    ->falseIcon('heroicon-o-x-circle')
                    ->trueColor('success')
                    ->falseColor('danger'),

                Tables\Columns\ToggleColumn::make('is_active')
                    ->label('启用'),

                Tables\Columns\TextColumn::make('sort_order')
                    ->label('排序')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('category_id')
                    ->label('目录')
                    ->options(fn () => KnowledgeCategory::query()
                        ->orderBy('sort_order')
                        ->orderBy('id')
                        ->pluck('name', 'id'))
                    ->placeholder('全部目录'),

                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('启用状态')
                    ->trueLabel('已启用')
                    ->falseLabel('已禁用'),

                Tables\Filters\TernaryFilter::make('vectorized')
                    ->label('向量化状态')
                    ->trueLabel('已向量化')
                    ->falseLabel('未向量化')
                    ->queries(
                        true: fn ($q) => $q->whereNotNull('vectorized_at'),
                        false: fn ($q) => $q->whereNull('vectorized_at'),
                    ),
            ])
            ->actions([
                Actions\EditAction::make(),
                Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Actions\BulkActionGroup::make([
                    Actions\DeleteBulkAction::make(),
                    Actions\BulkAction::make('vectorize')
                        ->label('重新向量化')
                        ->icon('heroicon-o-sparkles')
                        ->requiresConfirmation()
                        ->action(function (Collection $records): void {
                            $service = app(EmbeddingService::class);
                            $now     = now()->toDateTimeString();

                            foreach ($records as $item) {
                                $embedding = $service->embed($item->content);
                                if ($embedding === null) {
                                    continue;
                                }
                                $literal = $service->toVectorLiteral($embedding);
                                DB::statement(
                                    'UPDATE knowledge_items SET embedding = CAST(? AS vector), vectorized_at = ? WHERE id = ?',
                                    [$literal, $now, $item->id]
                                );
                            }
                        }),
                ]),
            ])
            ->defaultSort('sort_order');
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListKnowledgeItems::route('/'),
            'create' => Pages\CreateKnowledgeItem::route('/create'),
            'edit'   => Pages\EditKnowledgeItem::route('/{record}/edit'),
        ];
    }
}
