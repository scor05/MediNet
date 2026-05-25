<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        DB::statement('ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_channel_check');
        DB::statement("ALTER TABLE notifications ADD CONSTRAINT notifications_channel_check CHECK (channel IN ('email', 'sms', 'push', 'whatsapp'))");

        DB::statement('ALTER TABLE notification_preferences DROP CONSTRAINT IF EXISTS notification_preferences_channel_check');
        DB::statement("ALTER TABLE notification_preferences ADD CONSTRAINT notification_preferences_channel_check CHECK (channel IN ('email', 'sms', 'push', 'whatsapp'))");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::statement('ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_channel_check');
        DB::statement("ALTER TABLE notifications ADD CONSTRAINT notifications_channel_check CHECK (channel IN ('email', 'sms', 'push'))");

        DB::statement('ALTER TABLE notification_preferences DROP CONSTRAINT IF EXISTS notification_preferences_channel_check');
        DB::statement("ALTER TABLE notification_preferences ADD CONSTRAINT notification_preferences_channel_check CHECK (channel IN ('email', 'sms', 'push'))");
    }
};
