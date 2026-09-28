<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement(
            'ALTER TABLE notifications '
            .'DROP CONSTRAINT IF EXISTS notifications_type_check'
        );
        DB::statement(<<<'SQL'
            ALTER TABLE notifications
            ADD CONSTRAINT notifications_type_check
            CHECK (type IN (
                'reminder',
                'cancellation',
                'reschedule',
                'acceptance',
                'rejection',
                'waitlist_alert'
            ))
        SQL);

        DB::statement(
            'ALTER TABLE notifications '
            .'DROP CONSTRAINT IF EXISTS notifications_channel_check'
        );
        DB::statement(<<<'SQL'
            ALTER TABLE notifications
            ADD CONSTRAINT notifications_channel_check
            CHECK (channel IN ('email', 'sms', 'push', 'whatsapp'))
        SQL);
    }

    public function down(): void
    {
        DB::table('notifications')
            ->where('type', 'waitlist_alert')
            ->update(['type' => 'reminder']);
        DB::table('notifications')
            ->where('channel', 'whatsapp')
            ->update(['channel' => 'push']);

        DB::statement(
            'ALTER TABLE notifications '
            .'DROP CONSTRAINT IF EXISTS notifications_type_check'
        );
        DB::statement(<<<'SQL'
            ALTER TABLE notifications
            ADD CONSTRAINT notifications_type_check
            CHECK (type IN (
                'reminder',
                'cancellation',
                'reschedule',
                'acceptance',
                'rejection'
            ))
        SQL);

        DB::statement(
            'ALTER TABLE notifications '
            .'DROP CONSTRAINT IF EXISTS notifications_channel_check'
        );
        DB::statement(<<<'SQL'
            ALTER TABLE notifications
            ADD CONSTRAINT notifications_channel_check
            CHECK (channel IN ('email', 'sms', 'push'))
        SQL);
    }
};
