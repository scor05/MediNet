<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\ClientUser;

class AdminController extends Controller
{
    public function dashboard(Request $request)
    {
        $user = $request->user();

        $clientAdmin = ClientUser::where('id_user', $user->id)
            ->where('is_admin', true)
            ->where('is_active', true)
            ->first();

        return response()->json([
            'message' => 'Acceso autorizado como administrador de cliente.',
            'client_id' => $clientAdmin?->id_client,
        ]);
    }
}