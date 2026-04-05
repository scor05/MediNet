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

    // Se crea un nuevo usuario
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'     => 'required|string',
            'email'    => 'required|email|unique:users,email',
            'password' => 'required|string|min:8',
            'phone'    => 'nullable|string',
        ]);

        return response()->json($this->service->create($validated), 201);
    }

    // Se actualiza un usuario
    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'name'      => 'sometimes|string',
            'email'     => 'sometimes|email|unique:users,email,' . $id,
            'password'  => 'sometimes|string|min:8',
            'phone'     => 'nullable|string',
            'is_active' => 'sometimes|boolean',
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