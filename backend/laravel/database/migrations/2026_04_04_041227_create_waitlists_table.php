<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('waitlists', function (Blueprint $table) {
            $table->id();
            $table->foreignId('id_patient')->constrained('users');
            $table->foreignId('id_target_appointment')->constrained('appointments');
            $table->foreignId('id_fallback_appointment')->constrained('appointments');
            $table->text('status');
            $table->timestamps();
        });

        DB::statement("
            ALTER TABLE waitlists
            ADD CONSTRAINT waitlists_status_check
            CHECK (status IN ('active', 'notified', 'expired', 'fulfilled', 'cancelled'))
        ");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('waitlists');
    }
};
