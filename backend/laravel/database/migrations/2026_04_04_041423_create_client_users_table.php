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
        Schema::create('client_users', function (Blueprint $table) {
            $table->foreignId('id_client')->constrained('clients');
            $table->foreignId('id_user')->constrained('users');
            $table->integer('role');
            $table->boolean('is_admin')->default(false);
            $table->boolean('is_active')->default(true);

            $table->primary(['id_client', 'id_user']);
        });

        DB::statement("
            ALTER TABLE client_users
            ADD CONSTRAINT client_users_role_check
            CHECK (role IN (0, 1))
        ");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('client_users');
    }
};
