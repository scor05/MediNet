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
        Schema::create('schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('id_doctor')->constrained('users');
            $table->foreignId('id_clinic')->constrained('clinics');
            $table->integer('day_of_week');
            $table->time('start_time');
            $table->time('end_time');
            $table->boolean('is_active')->default(true);
            $table->integer('duration');
            $table->timestamps();
        });

        DB::statement('ALTER TABLE schedules ADD CONSTRAINT schedules_day_of_week_check CHECK (day_of_week BETWEEN 0 AND 6)');
        DB::statement('ALTER TABLE schedules ADD CONSTRAINT schedules_time_check CHECK (start_time < end_time)');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('schedules');
    }
};
