<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('chat_logs', function (Blueprint $table) {
            $table->id();
            $table->string('agent_id', 100)->nullable()->index();
            $table->enum('direction', ['inbound', 'outbound']);
            $table->string('channel', 50)->nullable();
            $table->string('account_id', 100)->nullable();
            $table->string('conversation_id', 100)->nullable()->index();
            $table->string('message_id', 100)->nullable();
            $table->string('sender', 200)->nullable();
            $table->text('content')->nullable();
            $table->boolean('success')->default(true);
            $table->string('error_msg', 500)->nullable();
            $table->string('session_key', 200)->nullable();
            $table->timestamp('occurred_at')->nullable()->index();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('chat_logs');
    }
};
