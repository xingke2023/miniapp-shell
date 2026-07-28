<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('industries', function (Blueprint $table) {
            $table->string('api_base', 200)->nullable()->after('description')
                ->comment('该行业菜单/标题/接口的外部后端 base（如 https://app2.xingke888.com/api）；留空=用本项目');
        });
    }

    public function down(): void
    {
        Schema::table('industries', function (Blueprint $table) {
            $table->dropColumn('api_base');
        });
    }
};
