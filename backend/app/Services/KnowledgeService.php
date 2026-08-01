<?php

namespace App\Services;

use App\Models\KnowledgeItem;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class KnowledgeService
{
    public function __construct(private readonly EmbeddingService $embeddingService) {}

    /**
     * 检索与 query 语义最相关的知识条目。
     * 优先使用向量相似度搜索，降级到关键词 ilike。
     */
    public function findRelevant(string $query, int $limit = 5): Collection
    {
        if (empty(trim($query))) {
            return collect();
        }

        $embedding = $this->embeddingService->embed($query);

        if ($embedding !== null) {
            $literal = $this->embeddingService->toVectorLiteral($embedding);

            $rows = DB::select(
                'SELECT id FROM knowledge_items
                 WHERE is_active = true AND embedding IS NOT NULL
                 ORDER BY embedding <=> CAST(? AS vector) LIMIT ?',
                [$literal, $limit]
            );

            if (! empty($rows)) {
                $ids     = array_column($rows, 'id');
                $indexed = KnowledgeItem::with('category')->findMany($ids)->keyBy('id');

                return collect($ids)
                    ->map(fn ($id) => $indexed[$id] ?? null)
                    ->filter()
                    ->values();
            }
        }

        // 降级：关键词 ilike（embedding API 不可用或无向量化条目）
        return $this->findByKeywords($query, $limit);
    }

    public function formatContext(Collection $items): string
    {
        if ($items->isEmpty()) {
            return '';
        }

        return $items->map(function (KnowledgeItem $item): string {
            $prefix = $item->category ? "【{$item->category->name}】\n" : '';

            return "{$prefix}{$item->content}";
        })->implode("\n\n---\n\n");
    }

    private function findByKeywords(string $query, int $limit): Collection
    {
        $words = array_values(array_filter(
            preg_split("/[\s，。！？、；：\"\u{201C}\u{201D}\u{2018}\u{2019}【】（）\[\]]+/u", trim($query)),
            fn (string $w) => mb_strlen($w) >= 2
        ));

        if (empty($words)) {
            return collect();
        }

        return KnowledgeItem::where('is_active', true)
            ->with('category')
            ->where(function ($q) use ($words) {
                foreach ($words as $word) {
                    $q->orWhere('content', 'ilike', "%{$word}%");
                }
            })
            ->orderBy('sort_order')
            ->orderBy('id')
            ->limit($limit)
            ->get();
    }
}
