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
        Schema::create('appointments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('id_schedule')->constrained('schedules');
            $table->foreignId('id_patient')->constrained('users')->nullable();
            $table->text('name_patient');
            $table->date('date');
            $table->text('status');
            $table->time('start_time');
            $table->foreignId('created_by')->constrained('users');
            $table->foreignId('last_updated_by')->constrained('users');
            $table->timestamps();
        });

        DB::statement("
            ALTER TABLE appointments
            ADD CONSTRAINT appointments_status_check
            CHECK (status IN ('requested', 'accepted', 'rejected', 'cancelled', 'rescheduled'))
        ");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('appointments');
    }
};
