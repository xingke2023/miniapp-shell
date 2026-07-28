<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 小程序聊天页底部快捷按钮（原写死在 chat.js 的 quickActions），改为后台可配。
        Schema::create('quick_actions', function (Blueprint $table) {
            $table->id();
            $table->string('key', 50)->comment('按钮标识（data-key，用于样式 qa-chip-{key}）');
            $table->string('emoji', 16)->nullable();
            $table->string('label', 50);
            $table->string('badge', 20)->nullable()->comment('角标文字，空则不显示');
            $table->string('action_type', 20)->default('prompt')->comment('prompt|web|open|menu');
            $table->text('prompt')->nullable()->comment('prompt/web 类型：发给 AI 的文字');
            $table->string('target_path', 200)->nullable()->comment('web/open 类型：web-view 路径，如 /inventory、/admin/sso');
            $table->string('target_title', 50)->nullable()->comment('web-view 页标题');
            $table->string('web_label', 50)->nullable()->comment('web 类型「打开完整页」按钮文字');
            $table->boolean('admin_only')->default(false)->comment('仅 is_admin 用户可见');
            $table->foreignId('store_id')->nullable()->comment('null=全门店通用，否则仅该门店');
            $table->boolean('enabled')->default(true);
            $table->integer('sort_order')->default(0);
            $table->timestamps();

            $table->index(['store_id', 'enabled', 'sort_order']);
        });

        // 子菜单项（action_type=menu 时弹出的 popover 列表）。
        Schema::create('quick_action_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('quick_action_id')->constrained()->cascadeOnDelete();
            $table->string('emoji', 16)->nullable();
            $table->string('label', 50);
            $table->string('desc', 100)->nullable()->comment('副标题说明');
            $table->string('item_type', 20)->default('prompt')->comment('route|prompt');
            $table->string('route', 200)->nullable()->comment('route 类型：小程序页路径，如 /pages/report/report');
            $table->text('prompt')->nullable()->comment('prompt 类型：发给 AI 的文字');
            $table->integer('sort_order')->default(0);
            $table->timestamps();

            $table->index(['quick_action_id', 'sort_order']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('quick_action_items');
        Schema::dropIfExists('quick_actions');
    }
};
