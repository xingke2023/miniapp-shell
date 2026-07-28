<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('industries', function (Blueprint $table) {
            $table->string('ai_path', 200)->nullable()->after('api_token')
                ->comment('外部行业 AI 聊天接口路径，如 /api/chat/message；留空默认 /ai/message');
        });
    }

    public function down(): void
    {
        Schema::table('industries', function (Blueprint $table) {
            $table->dropColumn('ai_path');
        });
    }
};
