<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\ClientUserService;

class ClientUserController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private ClientUserService $service)
    {
    }

    // Se obtienen todos los usuarios asignados a un cliente
    public function index($clientId)
    {
        return response()->json($this->service->getByClient($clientId));
    }

    // Se crea una nueva asignación de un usuario a un cliente
    public function store(Request $request, $clientId)
    {
        $validated = $request->validate([
            'id_user' => 'required|integer|exists:users,id',
            'role' => 'required|integer|in:0,1',
            'is_admin' => 'boolean',
        ]);
        return response()->json($this->service->create($clientId, $validated), 201);
    }

    // Se actualiza una asignación de un usuario a un cliente
    public function update(Request $request, $clientId, $userId)
    {
        $validated = $request->validate([
            'role' => 'integer|in:0,1',
            'is_admin' => 'boolean',
            'is_active' => 'boolean',
        ]);
        return response()->json($this->service->update($clientId, $userId, $validated));
    }

    // Se elimina la asignación de un usuario a un cliente
    public function destroy($clientId, $userId)
    {
        $this->service->delete($clientId, $userId);
        return response()->json(null, 204);
    }
}
