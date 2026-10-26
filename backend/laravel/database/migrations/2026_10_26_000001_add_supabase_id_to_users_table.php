<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Se agrega el identificador (sub) de Supabase Auth a los usuarios
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->uuid('supabase_id')->nullable()->unique()->after('email');
        });
    }

    /**
     * Se quita el identificador de Supabase Auth de los usuarios
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropUnique(['supabase_id']);
            $table->dropColumn('supabase_id');
        });
    }
};
