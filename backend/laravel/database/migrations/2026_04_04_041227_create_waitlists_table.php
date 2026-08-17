<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('waitlists', function (Blueprint $table) {
            $table->id();

            $table->foreignId('id_patient')
                ->constrained('users')
                ->cascadeOnDelete();

            $table->foreignId('id_target_appointment')
                ->constrained('appointments')
                ->cascadeOnDelete();

            $table->foreignId('id_fallback_appointment')
                ->nullable()
                ->constrained('appointments')
                ->nullOnDelete();

            $table->enum('status', [
                'waiting',
                'notified',
                'fulfilled',
                'cancelled',
            ])->default('waiting');

            $table->timestamps();

            $table->unique([
                'id_patient',
                'id_target_appointment',
            ]);

            $table->index(
                ['id_target_appointment', 'status', 'created_at', 'id'],
                'waitlists_target_status_created_idx'
            );
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('waitlists');
    }
};
