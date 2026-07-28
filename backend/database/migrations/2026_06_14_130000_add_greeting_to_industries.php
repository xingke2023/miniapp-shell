<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 每个行业进入聊天页后的欢迎语；null=小程序用「我是{title}」通用兜底。
        Schema::table('industries', function (Blueprint $table) {
            $table->text('greeting')->nullable()->after('description')
                ->comment('行业欢迎语（聊天页登录后展示）；留空小程序用通用兜底');
        });
    }

    public function down(): void
    {
        Schema::table('industries', function (Blueprint $table) {
            $table->dropColumn('greeting');
        });
    }
};
