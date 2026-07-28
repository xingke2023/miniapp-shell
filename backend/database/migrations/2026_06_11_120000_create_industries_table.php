<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 行业模版：小程序启动先选行业，每个行业一套底部快捷菜单（quick_actions.industry 关联 slug）。
        Schema::create('industries', function (Blueprint $table) {
            $table->id();
            $table->string('slug', 50)->unique()->comment('行业标识，如 fresh / restaurant；quick_actions.industry 用它过滤');
            $table->string('name', 50)->comment('行业名称，如 生鲜门店');
            $table->string('emoji', 16)->nullable()->comment('行业图标 emoji');
            $table->string('title', 100)->nullable()->comment('该行业聊天页顶栏品牌标题');
            $table->string('description', 200)->nullable()->comment('行业说明（选择页副标题）');
            $table->integer('sort_order')->default(0);
            $table->boolean('enabled')->default(true);
            $table->timestamps();

            $table->index(['enabled', 'sort_order']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('industries');
    }
};
