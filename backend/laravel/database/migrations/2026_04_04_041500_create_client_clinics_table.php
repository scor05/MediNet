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
        Schema::create('client_clinics', function (Blueprint $table) {
            $table->foreignId('id_client')->constrained('clients');
            $table->foreignId('id_clinic')->constrained('clinics');
            $table->boolean('is_active')->default(true);

            $table->primary(['id_client', 'id_clinic']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('client_clinics');
    }
};
