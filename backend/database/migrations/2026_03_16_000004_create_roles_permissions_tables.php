<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('roles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->nullable()->constrained()->nullOnDelete();
            $table->string('name', 100);
            $table->string('code', 50)->comment('SUPER_ADMIN, REGION_BUYER, STORE_MANAGER, STORE_STAFF');
            $table->text('description')->nullable();
            $table->tinyInteger('scope')->default(3)->comment('1:总部 2:区域 3:门店');
            $table->timestamps();

            $table->unique(['organization_id', 'code']);
        });

        Schema::create('permissions', function (Blueprint $table) {
            $table->id();
            $table->string('module', 50)->comment('模块标识');
            $table->string('code', 100)->unique()->comment('如 inventory.product.create');
            $table->string('name', 100);
            $table->tinyInteger('type')->default(2)->comment('1:菜单 2:操作 3:数据');
            $table->timestamps();

            $table->index(['module']);
        });

        Schema::create('role_permissions', function (Blueprint $table) {
            $table->foreignId('role_id')->constrained()->cascadeOnDelete();
            $table->foreignId('permission_id')->constrained()->cascadeOnDelete();
            $table->timestamp('created_at')->useCurrent();

            $table->primary(['role_id', 'permission_id']);
        });

        Schema::create('user_store_roles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('store_id')->nullable()->constrained()->cascadeOnDelete();
            $table->foreignId('region_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('role_id')->constrained()->cascadeOnDelete();
            $table->foreignId('granted_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('granted_at')->useCurrent();
            $table->timestamp('expired_at')->nullable();

            $table->index(['user_id', 'store_id']);
            $table->index(['store_id', 'role_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_store_roles');
        Schema::dropIfExists('role_permissions');
        Schema::dropIfExists('permissions');
        Schema::dropIfExists('roles');
    }
};
