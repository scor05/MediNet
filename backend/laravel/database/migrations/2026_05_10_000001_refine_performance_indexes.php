<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        DB::statement('CREATE EXTENSION IF NOT EXISTS pg_trgm');

        // Drop narrower indexes that are covered by the composite indexes below.
        DB::statement('DROP INDEX IF EXISTS client_users_id_user_is_active_index');
        DB::statement('DROP INDEX IF EXISTS schedules_id_doctor_index');
        DB::statement('DROP INDEX IF EXISTS schedules_id_clinic_index');
        DB::statement('DROP INDEX IF EXISTS schedules_id_doctor_is_active_index');
        DB::statement('DROP INDEX IF EXISTS appointments_date_index');
        DB::statement('DROP INDEX IF EXISTS appointments_id_schedule_date_status_index');
        DB::statement('DROP INDEX IF EXISTS clinics_id_client_index');

        // Membership lookups by user/client, role and active state.
        DB::statement('CREATE INDEX IF NOT EXISTS client_users_user_active_role_client_idx ON client_users (id_user, is_active, role, id_client)');
        DB::statement('CREATE INDEX IF NOT EXISTS client_users_client_role_active_user_idx ON client_users (id_client, role, is_active, id_user)');

        // Schedule lookups for slot availability, calendar joins and public listings.
        DB::statement('CREATE INDEX IF NOT EXISTS schedules_doctor_active_day_clinic_start_idx ON schedules (id_doctor, is_active, day_of_week, id_clinic, start_time)');
        DB::statement('CREATE INDEX IF NOT EXISTS schedules_clinic_active_doctor_idx ON schedules (id_clinic, is_active, id_doctor)');

        // Appointment lookups for slot conflicts, availability checks and date-ordered calendars.
        DB::statement("CREATE INDEX IF NOT EXISTS appointments_schedule_date_start_active_idx ON appointments (id_schedule, date, start_time) WHERE status NOT IN ('rejected', 'cancelled')");
        DB::statement('CREATE INDEX IF NOT EXISTS appointments_date_start_status_idx ON appointments (date, start_time, status)');

        // Clinic listings and active clinic filters.
        DB::statement('CREATE INDEX IF NOT EXISTS clinics_client_active_idx ON clinics (id_client, is_active)');

        // ILIKE search support for PostgreSQL.
        DB::statement('CREATE INDEX IF NOT EXISTS users_name_trgm_idx ON users USING gin (name gin_trgm_ops)');
        DB::statement('CREATE INDEX IF NOT EXISTS users_email_trgm_idx ON users USING gin (email gin_trgm_ops)');
        DB::statement('CREATE INDEX IF NOT EXISTS clinics_name_trgm_idx ON clinics USING gin (name gin_trgm_ops)');
    }

    public function down(): void
    {
        DB::statement('DROP INDEX IF EXISTS clinics_name_trgm_idx');
        DB::statement('DROP INDEX IF EXISTS users_email_trgm_idx');
        DB::statement('DROP INDEX IF EXISTS users_name_trgm_idx');
        DB::statement('DROP INDEX IF EXISTS clinics_client_active_idx');
        DB::statement('DROP INDEX IF EXISTS appointments_date_start_status_idx');
        DB::statement('DROP INDEX IF EXISTS appointments_schedule_date_start_active_idx');
        DB::statement('DROP INDEX IF EXISTS schedules_clinic_active_doctor_idx');
        DB::statement('DROP INDEX IF EXISTS schedules_doctor_active_day_clinic_start_idx');
        DB::statement('DROP INDEX IF EXISTS client_users_client_role_active_user_idx');
        DB::statement('DROP INDEX IF EXISTS client_users_user_active_role_client_idx');

        DB::statement('CREATE INDEX IF NOT EXISTS client_users_id_user_is_active_index ON client_users (id_user, is_active)');
        DB::statement('CREATE INDEX IF NOT EXISTS schedules_id_doctor_index ON schedules (id_doctor)');
        DB::statement('CREATE INDEX IF NOT EXISTS schedules_id_clinic_index ON schedules (id_clinic)');
        DB::statement('CREATE INDEX IF NOT EXISTS schedules_id_doctor_is_active_index ON schedules (id_doctor, is_active)');
        DB::statement('CREATE INDEX IF NOT EXISTS appointments_date_index ON appointments (date)');
        DB::statement('CREATE INDEX IF NOT EXISTS appointments_id_schedule_date_status_index ON appointments (id_schedule, date, status)');
        DB::statement('CREATE INDEX IF NOT EXISTS clinics_id_client_index ON clinics (id_client)');
    }
};
