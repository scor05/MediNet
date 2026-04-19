<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\ClinicService;

class ClinicController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private ClinicService $service)
    {
    }

    // Se obtienen todas las clínicas de un cliente
    public function index(int $clientId)
    {
        return response()->json($this->service->getByClient($clientId));
    }

    // Se obtiene una clínica por su ID
    public function show(int $id)
    {
        return response()->json($this->service->getById($id));
    }

    // Se crea una nueva clínica
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'address' => 'required|string',
            'phone' => 'required|string|unique:clinics,phone',
            'email' => 'required|email|unique:clinics,email',
            'id_client' => 'required|exists:clients,id',
        ], [
            'phone.unique' => 'El teléfono ya es usado por otra clínica',
            'email.unique' => 'El correo ya es usado por otra clínica',
        ]);

        return response()->json($this->service->create($validated), 201);
    }

    // Se actualiza una clínica
    public function update(Request $request, int $id)
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'address' => 'sometimes|string',
            'phone' => 'sometimes|string|unique:clinics,phone,' . $id,
            'email' => 'sometimes|email|unique:clinics,email,' . $id,
            'is_active' => 'sometimes|boolean',
        ], [
            'phone.unique' => 'El teléfono ya es usado por otra clínica',
            'email.unique' => 'El correo ya es usado por otra clínica',
        ]);

        return response()->json($this->service->update($id, $validated));
    }

    // Se elimina una clínica
    public function destroy(int $id)
    {
        $this->service->delete($id);
        return response()->json(null, 204);
    }
}