<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $dim = config('ai.embedding_dimensions', 1536);

        DB::statement("ALTER TABLE knowledge_items ADD COLUMN IF NOT EXISTS embedding vector({$dim})");
        DB::statement('ALTER TABLE knowledge_items ADD COLUMN IF NOT EXISTS vectorized_at TIMESTAMP NULL');

        // ivfflat 索引：lists 建议为 sqrt(行数)，知识库小型场景 10 足够
        DB::statement('CREATE INDEX IF NOT EXISTS knowledge_items_embedding_idx
            ON knowledge_items USING ivfflat (embedding vector_cosine_ops) WITH (lists = 10)');
    }

    public function down(): void
    {
        DB::statement('DROP INDEX IF EXISTS knowledge_items_embedding_idx');
        DB::statement('ALTER TABLE knowledge_items DROP COLUMN IF EXISTS vectorized_at');
        DB::statement('ALTER TABLE knowledge_items DROP COLUMN IF EXISTS embedding');
    }
};
