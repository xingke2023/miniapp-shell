<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('weather_logs', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('store_id')->index();
            $table->date('date');
            $table->string('city', 50)->default('香港');
            $table->string('weather', 50)->comment('天气状况，如晴、多云、阵雨');
            $table->smallInteger('temperature_high')->comment('最高气温（摄氏度）');
            $table->smallInteger('temperature_low')->comment('最低气温（摄氏度）');
            $table->tinyInteger('humidity')->comment('湿度百分比');
            $table->tinyInteger('rain_probability')->comment('降雨概率百分比');
            $table->tinyInteger('uv_index')->comment('紫外线指数 1-11');
            $table->string('description', 255)->comment('门店参考天气提示');
            $table->timestamps();

            $table->unique(['date', 'city']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('weather_logs');
    }
};
