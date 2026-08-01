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
        Schema::table('quick_action_items', function (Blueprint $table) {
            $table->string('emoji', 50)->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('quick_action_items', function (Blueprint $table) {
            $table->string('emoji', 16)->nullable()->change();
        });
    }
};
