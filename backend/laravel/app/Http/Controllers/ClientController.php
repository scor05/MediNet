<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\ClientService;

class ClientController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private ClientService $service)
    {
    }

    // Se obtienen todos los clientes
    public function index()
    {
        return response()->json($this->service->getAll());
    }

    // Se obtiene un cliente por su id
    public function show($id)
    {
        return response()->json($this->service->getById($id));
    }

    // Se crea un nuevo cliente
    public function store(Request $request)
    {
        $validated = $request->validate([
            'nit'     => 'required|string|max:20',
            'name'    => 'required|string|max:255',
            'id_user' => 'sometimes|integer|exists:users,id',
        ]);
        return response()->json($this->service->create($validated), 201);
    }

    // Se actualiza un cliente
    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'nit' => 'sometimes|string|max:20',
            'name' => 'sometimes|string|max:255',
            'is_active' => 'sometimes|boolean',
        ]);
        return response()->json($this->service->update($id, $validated));
    }

    // Se elimina un cliente
    public function destroy($id)
    {
        $this->service->delete($id);
        return response()->json(null, 204);
    }
}
