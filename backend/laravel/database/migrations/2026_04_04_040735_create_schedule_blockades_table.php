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
        Schema::create('schedule_blockades', function (Blueprint $table) {
            $table->id();
            $table->foreignId('id_schedule')->constrained('schedules');
            $table->date('date');
            $table->time('start_time');
            $table->time('end_time');
        });

        DB::statement('ALTER TABLE schedule_blockades ADD CONSTRAINT schedule_blockades_time_check CHECK (start_time < end_time)');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('schedule_blockades');
    }
};
