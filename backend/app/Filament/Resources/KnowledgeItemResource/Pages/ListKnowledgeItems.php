<?php

namespace App\Filament\Resources\KnowledgeItemResource\Pages;

use App\Filament\Resources\KnowledgeItemResource;
use App\Models\KnowledgeItem;
use App\Services\EmbeddingService;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;
use Illuminate\Support\Facades\DB;

class ListKnowledgeItems extends ListRecords
{
    protected static string $resource = KnowledgeItemResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('vectorize_all')
                ->label('全部向量化')
                ->icon('heroicon-o-sparkles')
                ->color('warning')
                ->requiresConfirmation()
                ->modalHeading('全部向量化')
                ->modalDescription('将对所有未向量化的启用条目生成向量嵌入，条目较多时耗时较长。')
                ->action(function (): void {
                    $service = app(EmbeddingService::class);
                    $now     = now()->toDateTimeString();

                    KnowledgeItem::where('is_active', true)
                        ->whereNull('vectorized_at')
                        ->each(function (KnowledgeItem $item) use ($service, $now): void {
                            $embedding = $service->embed($item->content);
                            if ($embedding === null) {
                                return;
                            }
                            $literal = $service->toVectorLiteral($embedding);
                            DB::statement(
                                'UPDATE knowledge_items SET embedding = CAST(? AS vector), vectorized_at = ? WHERE id = ?',
                                [$literal, $now, $item->id]
                            );
                        });
                }),

            Actions\CreateAction::make(),
        ];
    }
}
