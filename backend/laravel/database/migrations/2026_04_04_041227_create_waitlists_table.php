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
                ->constrained('patients')
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
                'cancelled'
            ])->default('waiting');

            $table->timestamps();

            $table->unique([
                'id_patient',
                'id_target_appointment'
            ]);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('waitlists');
    }
};