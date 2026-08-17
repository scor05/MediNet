<?php

namespace App\Http\Controllers;

use App\Services\WaitlistService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class WaitlistController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private WaitlistService $service)
    {
    }

    // Se obtienen todos los registros de lista de espera
    public function index()
    {
        return response()->json($this->service->getAll());
    }

    // Se obtiene un registro por su id
    public function show(int $id)
    {
        return response()->json($this->service->getById($id));
    }

    // Se obtienen los registros de un paciente
    public function indexByPatient(int $patientId)
    {
        return response()->json($this->service->getByPatient($patientId));
    }

    // Se crea un nuevo registro de lista de espera
    public function store(Request $request)
    {
        $validated = $request->validate([
            'id_patient' => 'required|integer|exists:users,id',
            'id_target_appointment' => 'required|integer|exists:appointments,id',
            'id_fallback_appointment' => 'required|integer|exists:appointments,id',
            'status' => [
                'sometimes',
                Rule::in(['active', 'notified', 'expired', 'fulfilled', 'cancelled']),
            ],
        ]);

        // Status por defecto
        if (!isset($validated['status'])) {
            $validated['status'] = 'active';
        }

        return response()->json($this->service->create($validated), 201);
    }

    // Se actualiza un registro de lista de espera
    public function update(Request $request, int $id)
    {
        $validated = $request->validate([
            'id_patient' => 'sometimes|integer|exists:users,id',
            'id_target_appointment' => 'sometimes|integer|exists:appointments,id',
            'id_fallback_appointment' => 'sometimes|integer|exists:appointments,id',
            'status' => [
                'sometimes',
                Rule::in(['active', 'notified', 'expired', 'fulfilled', 'cancelled']),
            ],
        ]);

        return response()->json($this->service->update($id, $validated));
    }

    // Se elimina un registro de lista de espera
    public function destroy(int $id)
    {
        $this->service->delete($id);
        return response()->json(null, 204);
    }
}
