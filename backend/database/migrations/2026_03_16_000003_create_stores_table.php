<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('stores', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignId('region_id')->nullable()->constrained()->nullOnDelete();
            $table->string('name', 100);
            $table->string('code', 50)->nullable();
            $table->string('address', 300)->nullable();
            $table->string('province', 50)->nullable();
            $table->string('city', 50)->nullable();
            $table->string('district', 50)->nullable();
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->foreignId('manager_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('business_hours', 100)->nullable();
            $table->tinyInteger('status')->default(1)->comment('0:关闭 1:正常 2:装修中');
            $table->json('settings')->nullable()->comment('门店级配置，覆盖总部默认值');
            $table->date('opened_at')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['organization_id', 'status']);
            $table->index(['region_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('stores');
    }
};
