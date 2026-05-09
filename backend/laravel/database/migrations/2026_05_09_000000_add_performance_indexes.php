<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        // client_users: búsquedas por id_user solo (el PK compuesto no ayuda en este caso)
        Schema::table('client_users', function (Blueprint $table) {
            $table->index(['id_user', 'is_active'], 'client_users_id_user_is_active_index');
        });

        // schedules: búsquedas por doctor y detección de overlaps
        Schema::table('schedules', function (Blueprint $table) {
            $table->index('id_doctor', 'schedules_id_doctor_index');
            $table->index('id_clinic', 'schedules_id_clinic_index');
            $table->index(['id_doctor', 'is_active'], 'schedules_id_doctor_is_active_index');
        });

        // appointments: slot conflict check y filtros de calendario
        Schema::table('appointments', function (Blueprint $table) {
            $table->index('id_patient', 'appointments_id_patient_index');
            $table->index('date', 'appointments_date_index');
            $table->index(['id_schedule', 'date', 'status'], 'appointments_id_schedule_date_status_index');
        });

        // clinics: búsqueda por cliente
        Schema::table('clinics', function (Blueprint $table) {
            $table->index('id_client', 'clinics_id_client_index');
        });
    }

    public function down(): void
    {
        Schema::table('client_users', function (Blueprint $table) {
            $table->dropIndex('client_users_id_user_is_active_index');
        });

        Schema::table('schedules', function (Blueprint $table) {
            $table->dropIndex('schedules_id_doctor_index');
            $table->dropIndex('schedules_id_clinic_index');
            $table->dropIndex('schedules_id_doctor_is_active_index');
        });

        Schema::table('appointments', function (Blueprint $table) {
            $table->dropIndex('appointments_id_patient_index');
            $table->dropIndex('appointments_date_index');
            $table->dropIndex('appointments_id_schedule_date_status_index');
        });

        Schema::table('clinics', function (Blueprint $table) {
            $table->dropIndex('clinics_id_client_index');
        });
    }
};
