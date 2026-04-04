<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\ClientUserService;

class ClientUserController extends Controller
{
    public function __construct(private ClientUserService $service)
    {
    }

    public function index($clientId)
    {
        return response()->json($this->service->getByClient($clientId));
    }

    public function store(Request $request, $clientId)
    {
        $validated = $request->validate([
            'id_user' => 'required|integer|exists:users,id',
            'role' => 'required|in:0,1',
            'is_admin' => 'boolean',
        ]);
        return response()->json($this->service->create($clientId, $validated), 201);
    }

    public function update(Request $request, $clientId, $userId)
    {
        $validated = $request->validate([
            'role' => 'in:0,1',
            'is_admin' => 'boolean',
            'is_active' => 'boolean',
        ]);
        return response()->json($this->service->update($clientId, $userId, $validated));
    }

    public function destroy($clientId, $userId)
    {
        $this->service->delete($clientId, $userId);
        return response()->json(null, 204);
    }
}
