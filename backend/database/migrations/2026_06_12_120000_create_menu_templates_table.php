<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 菜单模版：每个行业可建多套底部菜单，其中 is_active=true 的为当前生效。
        Schema::create('menu_templates', function (Blueprint $table) {
            $table->id();
            $table->string('industry', 50)->comment('归属行业 slug（关联 industries.slug）');
            $table->string('name', 50)->comment('模版名，如 默认模版 / 完整版 / 促销版');
            $table->boolean('is_active')->default(false)->comment('该行业当前生效的模版（每行业仅一个 true）');
            $table->integer('sort_order')->default(0);
            $table->timestamps();

            $table->index(['industry', 'is_active']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('menu_templates');
    }
};
