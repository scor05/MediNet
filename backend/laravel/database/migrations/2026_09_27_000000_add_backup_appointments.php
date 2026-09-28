<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('waitlists', function (Blueprint $table) {
            $table->timestamp('backup_declined_at')->nullable();
            $table->foreignId('id_backup_appointment')
                ->nullable()
                ->after('id_fallback_appointment')
                ->unique()
                ->constrained('appointments')
                ->nullOnDelete();
        });

        DB::statement('ALTER TABLE appointments DROP CONSTRAINT IF EXISTS appointments_status_check');
        DB::statement(<<<'SQL'
            ALTER TABLE appointments
            ADD CONSTRAINT appointments_status_check
            CHECK (status IN (
                'requested',
                'accepted',
                'rejected',
                'cancelled',
                'rescheduled',
                'backup_pending',
                'backup_accepted',
                'backup_cancelled'
            ))
        SQL);
    }

    public function down(): void
    {
        DB::table('appointments')
            ->whereIn('status', [
                'backup_pending',
                'backup_accepted',
                'backup_cancelled',
            ])
            ->update(['status' => 'cancelled']);

        Schema::table('waitlists', function (Blueprint $table) {
            $table->dropConstrainedForeignId('id_backup_appointment');
            $table->dropColumn('backup_declined_at');
        });

        DB::statement('ALTER TABLE appointments DROP CONSTRAINT IF EXISTS appointments_status_check');
        DB::statement(<<<'SQL'
            ALTER TABLE appointments
            ADD CONSTRAINT appointments_status_check
            CHECK (status IN (
                'requested',
                'accepted',
                'rejected',
                'cancelled',
                'rescheduled'
            ))
        SQL);
    }
};
