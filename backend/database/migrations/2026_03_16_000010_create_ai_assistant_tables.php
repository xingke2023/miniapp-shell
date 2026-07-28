<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ai_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('store_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->uuid('session_uuid')->unique();
            $table->tinyInteger('channel')->default(1)->comment('1:APP语音 2:APP文字 3:企业微信 4:Web');
            $table->tinyInteger('status')->default(1)->comment('1:进行中 2:已完成 3:异常');
            $table->timestamp('started_at')->useCurrent();
            $table->timestamp('ended_at')->nullable();
            $table->json('context')->nullable()->comment('多轮对话上下文');
            $table->timestamps();

            $table->index(['store_id', 'user_id']);
            $table->index(['started_at']);
        });

        Schema::create('ai_messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('session_id')->constrained('ai_sessions')->cascadeOnDelete();
            $table->tinyInteger('role')->comment('1:用户 2:AI助手');
            $table->tinyInteger('input_type')->default(1)->comment('1:文字 2:语音 3:图片 4:混合');
            $table->text('raw_content')->nullable()->comment('原始文字输入');
            $table->string('voice_url', 500)->nullable();
            $table->json('image_urls')->nullable();
            $table->text('transcribed_text')->nullable()->comment('语音转文字结果');
            $table->text('ocr_text')->nullable()->comment('图片OCR结果');
            $table->text('ai_response')->nullable();
            $table->string('intent', 100)->nullable()->comment('识别的意图类型');
            $table->json('entities')->nullable()->comment('提取的实体（商品名、数量等）');
            $table->decimal('confidence', 5, 4)->nullable()->comment('意图置信度');
            $table->string('dispatched_module', 50)->nullable()->comment('分发到的功能模块');
            $table->unsignedBigInteger('dispatched_action_id')->nullable()->comment('触发的业务记录ID');
            $table->integer('processing_time_ms')->nullable();
            $table->timestamp('created_at')->useCurrent();

            $table->index(['session_id']);
            $table->index(['intent', 'created_at']);
        });

        Schema::create('ai_command_templates', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->nullable()->constrained()->nullOnDelete();
            $table->string('intent', 100)->comment('意图标识');
            $table->string('module', 50)->comment('目标模块');
            $table->string('name', 100);
            $table->json('trigger_phrases')->nullable()->comment('触发词数组');
            $table->json('required_entities')->nullable()->comment('必需实体字段列表');
            $table->json('optional_entities')->nullable()->comment('可选实体字段列表');
            $table->string('action_handler', 100)->nullable()->comment('后端处理类/方法名');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();

            $table->index(['intent', 'is_active']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ai_command_templates');
        Schema::dropIfExists('ai_messages');
        Schema::dropIfExists('ai_sessions');
    }
};
