<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 通用 key-value 设置（小程序标题等品牌/文案配置，后台可改）。
        Schema::create('app_settings', function (Blueprint $table) {
            $table->id();
            $table->string('key', 100)->unique()->comment('设置键，如 miniprogram_title');
            $table->text('value')->nullable()->comment('设置值');
            $table->string('label', 100)->nullable()->comment('后台显示的中文说明');
            $table->integer('sort_order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('app_settings');
    }
};
