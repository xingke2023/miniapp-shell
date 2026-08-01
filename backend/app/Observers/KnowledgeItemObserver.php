<?php

namespace App\Observers;

use App\Models\KnowledgeItem;
use App\Services\EmbeddingService;
use Illuminate\Support\Facades\DB;

class KnowledgeItemObserver
{
    public function __construct(private readonly EmbeddingService $embeddingService) {}

    public function saved(KnowledgeItem $item): void
    {
        if (! $item->wasChanged('content') && ! $item->wasRecentlyCreated) {
            return;
        }

        $embedding = $this->embeddingService->embed($item->content);

        if ($embedding === null) {
            return;
        }

        $literal = $this->embeddingService->toVectorLiteral($embedding);
        $now     = now()->toDateTimeString();

        DB::statement(
            'UPDATE knowledge_items SET embedding = CAST(? AS vector), vectorized_at = ? WHERE id = ?',
            [$literal, $now, $item->id]
        );

        $item->setRawAttributes(array_merge($item->getRawOriginal(), ['vectorized_at' => $now]), true);
    }
}
