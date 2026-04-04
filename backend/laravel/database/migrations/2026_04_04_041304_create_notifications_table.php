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
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('id_user')->constrained('users');
            $table->text('type');
            $table->text('message');
            $table->timestamp('sent_at');
            $table->text('channel');
        });

        DB::statement("
            ALTER TABLE notifications
            ADD CONSTRAINT notifications_type_check
            CHECK (type IN ('reminder', 'cancellation', 'reschedule', 'acceptance', 'rejection'))
        ");

        DB::statement("
            ALTER TABLE notifications
            ADD CONSTRAINT notifications_channel_check
            CHECK (channel IN ('email', 'sms', 'push'))
        ");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};
