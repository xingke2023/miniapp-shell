<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('menu_templates', function (Blueprint $table) {
            $table->jsonb('settings')->nullable()->after('sort_order')
                ->comment('模板专属应用设置，覆盖全局 app_settings；留空则回退全局值');
        });
    }

    public function down(): void
    {
        Schema::table('menu_templates', function (Blueprint $table) {
            $table->dropColumn('settings');
        });
    }
};
