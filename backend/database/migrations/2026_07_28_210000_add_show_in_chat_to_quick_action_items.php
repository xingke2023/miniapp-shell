<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('quick_action_items', function (Blueprint $table) {
            $table->boolean('show_in_chat')->default(true)->after('sort_order');
        });
    }

    public function down(): void
    {
        Schema::table('quick_action_items', function (Blueprint $table) {
            $table->dropColumn('show_in_chat');
        });
    }
};
