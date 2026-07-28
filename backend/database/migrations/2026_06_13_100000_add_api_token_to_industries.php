<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('industries', function (Blueprint $table) {
            $table->text('api_token')->nullable()->after('api_base')
                ->comment('外部行业服务账号 token；随 /api/industries 返回，小程序无需弹登录框直接使用');
        });
    }

    public function down(): void
    {
        Schema::table('industries', function (Blueprint $table) {
            $table->dropColumn('api_token');
        });
    }
};
