<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\ClientClinicService;

class ClientClinicController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private ClientClinicService $service)
    {
    }

    // Se obtienen todas las clínicas asignadas a un cliente
    public function index($clientId)
    {
        return response()->json($this->service->getByClient($clientId));
    }

    // Se crea una nueva asignación de clínica a un cliente
    public function store(Request $request, $clientId)
    {
        $validated = $request->validate([
            'id_clinic' => 'required|integer|exists:clinics,id',
        ]);
        return response()->json($this->service->create($clientId, $validated), 201);
    }

    // Se actualiza una asignación de clínica a un cliente
    public function update(Request $request, $clientId, $clinicId)
    {
        $validated = $request->validate([
            'is_active' => 'boolean',
        ]);
        return response()->json($this->service->update($clientId, $clinicId, $validated));
    }

    // Se elimina la asignación de una clínica a un cliente
    public function destroy($clientId, $clinicId)
    {
        $this->service->delete($clientId, $clinicId);
        return response()->json(null, 204);
    }
}
