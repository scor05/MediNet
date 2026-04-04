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
        Schema::create('notification_preferences', function (Blueprint $table) {
            $table->foreignId('id_user')->constrained('users');
            $table->text('channel');

            $table->primary(['id_user', 'channel']);
        });

        DB::statement("
            ALTER TABLE notification_preferences
            ADD CONSTRAINT notification_preferences_channel_check
            CHECK (channel IN ('email', 'sms', 'push'))
        ");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('notification_preferences');
    }
};
