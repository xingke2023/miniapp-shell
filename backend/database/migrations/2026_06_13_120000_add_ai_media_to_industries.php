<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('industries', function (Blueprint $table): void {
            $table->boolean('ai_media')->default(false)->after('ai_path')
                ->comment('该行业聊天是否启用语音/拍照/相册/文件输入');
        });
    }

    public function down(): void
    {
        Schema::table('industries', function (Blueprint $table): void {
            $table->dropColumn('ai_media');
        });
    }
};
