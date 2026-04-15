<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\UserService;

class UserController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private UserService $service)
    {
    }

    // Se obtienen todos los usuarios
    public function index()
    {
        return response()->json($this->service->getAll());
    }

    // Se obtiene un usuario por su ID
    public function show($id)
    {
        return response()->json($this->service->getById($id));
    }

    // Se actualiza un usuario
    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . $id,
            'phone' => 'sometimes|nullable|string|max:20',
            'is_active' => 'sometimes|boolean',
        ], [
            'email.unique' => 'Este correo ya está registrado.',
        ]);

        return response()->json($this->service->update($id, $validated));
    }

    // Se elimina un usuario
    public function destroy($id)
    {
        $this->service->delete($id);
        return response()->json(null, 204);
    }
}