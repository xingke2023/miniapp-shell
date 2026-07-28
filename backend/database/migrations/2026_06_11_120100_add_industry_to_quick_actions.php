<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 给快捷按钮加「所属行业」维度：null = 全行业通用，否则仅该行业 slug 显示。
        Schema::table('quick_actions', function (Blueprint $table) {
            $table->string('industry', 50)->nullable()->after('store_id')
                ->comment('所属行业 slug（关联 industries.slug）；null=全行业通用');
            $table->index('industry');
        });

        // 回填现有种子数据：生鲜业务按钮归 fresh；天气/使用说明/后台管理保持 null（全行业通用）。
        DB::table('quick_actions')
            ->whereIn('key', ['inventory', 'sales', 'damage', 'purchase', 'report'])
            ->update(['industry' => 'fresh']);
    }

    public function down(): void
    {
        Schema::table('quick_actions', function (Blueprint $table) {
            $table->dropIndex(['industry']);
            $table->dropColumn('industry');
        });
    }
};
