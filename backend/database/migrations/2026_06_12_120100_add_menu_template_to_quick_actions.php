<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 按钮归属某套菜单模版；通用按钮（industry 为 null）保持 menu_template_id 为 null。
        Schema::table('quick_actions', function (Blueprint $table) {
            $table->foreignId('menu_template_id')->nullable()->after('industry')
                ->constrained()->nullOnDelete();
        });

        // 回填：为现有按钮里出现过的每个非空行业建一条「默认模版」(生效)，并把该行业按钮挂进去。
        $industries = DB::table('quick_actions')
            ->whereNotNull('industry')
            ->distinct()
            ->pluck('industry');

        foreach ($industries as $slug) {
            $templateId = DB::table('menu_templates')->insertGetId([
                'industry' => $slug,
                'name' => '默认模版',
                'is_active' => true,
                'sort_order' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            DB::table('quick_actions')
                ->where('industry', $slug)
                ->update(['menu_template_id' => $templateId]);
        }
    }

    public function down(): void
    {
        Schema::table('quick_actions', function (Blueprint $table) {
            $table->dropForeign(['menu_template_id']);
            $table->dropColumn('menu_template_id');
        });
    }
};
