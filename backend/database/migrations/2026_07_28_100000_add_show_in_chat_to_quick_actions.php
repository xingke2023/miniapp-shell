<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('quick_actions', function (Blueprint $table) {
            $table->boolean('show_in_chat')->default(false)->after('admin_only');
        });

        // 默认：menu 类型按钮自动勾选（子菜单展开到聊天区）
        DB::table('quick_actions')
            ->where('action_type', 'menu')
            ->update(['show_in_chat' => true]);
    }

    public function down(): void
    {
        Schema::table('quick_actions', function (Blueprint $table) {
            $table->dropColumn('show_in_chat');
        });
    }
};
