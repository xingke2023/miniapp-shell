<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('saas_integrations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignId('store_id')->nullable()->constrained()->cascadeOnDelete();
            $table->string('platform', 50)->comment('wework, dingtalk, pos_system, erp...');
            $table->string('app_id', 200)->nullable();
            $table->text('app_secret')->nullable()->comment('加密存储');
            $table->text('access_token')->nullable()->comment('加密存储');
            $table->timestamp('token_expires_at')->nullable();
            $table->string('webhook_url', 500)->nullable();
            $table->json('config')->nullable()->comment('平台特定配置参数');
            $table->tinyInteger('status')->default(1)->comment('0:禁用 1:正常 2:故障');
            $table->timestamp('last_sync_at')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['organization_id', 'platform']);
            $table->index(['store_id', 'platform']);
        });

        Schema::create('wework_users', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('wework_userid', 100)->unique();
            $table->string('wework_openid', 100)->nullable();
            $table->json('department_ids')->nullable();
            $table->timestamp('bound_at')->useCurrent();

            $table->index(['user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wework_users');
        Schema::dropIfExists('saas_integrations');
    }
};
