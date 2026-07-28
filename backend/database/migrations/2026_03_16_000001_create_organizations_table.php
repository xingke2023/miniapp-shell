<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('organizations', function (Blueprint $table) {
            $table->id();
            $table->string('name', 100);
            $table->string('code', 50)->unique();
            $table->string('logo_url', 500)->nullable();
            $table->string('contact_phone', 20)->nullable();
            $table->json('settings')->nullable()->comment('系统配置：功能开关、AI参数全局默认值');
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('organizations');
    }
};
