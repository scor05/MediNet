<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement('ALTER TABLE waitlists DROP CONSTRAINT IF EXISTS waitlists_status_check');
        DB::statement("UPDATE waitlists SET status = 'waiting' WHERE status = 'active'");
        DB::statement("UPDATE waitlists SET status = 'cancelled' WHERE status = 'expired'");
        DB::statement('ALTER TABLE waitlists ALTER COLUMN id_fallback_appointment DROP NOT NULL');
        DB::statement(<<<'SQL'
            ALTER TABLE waitlists
            ADD CONSTRAINT waitlists_status_check
            CHECK (status IN ('waiting', 'notified', 'fulfilled', 'cancelled'))
        SQL);
        DB::statement(<<<'SQL'
            CREATE INDEX IF NOT EXISTS waitlists_target_status_created_idx
            ON waitlists (id_target_appointment, status, created_at, id)
        SQL);
    }

    public function down(): void
    {
        DB::statement('DROP INDEX IF EXISTS waitlists_target_status_created_idx');
        DB::statement('ALTER TABLE waitlists DROP CONSTRAINT IF EXISTS waitlists_status_check');
        DB::statement("UPDATE waitlists SET status = 'notified' WHERE status = 'fulfilled'");
        DB::statement(<<<'SQL'
            ALTER TABLE waitlists
            ADD CONSTRAINT waitlists_status_check
            CHECK (status IN ('waiting', 'notified', 'cancelled'))
        SQL);
    }
};
