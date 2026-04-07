<?php

namespace App\Http\Controllers;

use App\Services\AppointmentService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class AppointmentController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private AppointmentService $service)
    {
    }

    // Se obtienen todas las citas
    public function index()
    {
        return response()->json($this->service->getAll());
    }

    // Se obtiene una cita por su id
    public function show(int $id)
    {
        return response()->json($this->service->getById($id));
    }

    // Se crea una nueva cita
    public function store(Request $request)
    {
        $validated = $request->validate([
            'id_schedule' => 'required|integer|exists:schedules,id',
            'id_patient' => 'required|integer|exists:users,id',
            'date' => 'required|date',
            'status' => [
                'required',
                Rule::in([
                    'requested',
                    'accepted',
                    'rejected',
                    'cancelled',
                    'rescheduled',
                ])
            ],
            'start_time' => 'required|date_format:H:i:s',
            'created_by' => 'required|integer|exists:users,id',
            'updated_by' => 'required|integer|exists:users,id',
        ]);

        return response()->json($this->service->create($validated), 201);
    }

    // Se actualiza una cita
    public function update(Request $request, int $id)
    {
        $validated = $request->validate([
            'id_schedule' => 'sometimes|integer|exists:schedules,id',
            'id_patient' => 'sometimes|integer|exists:users,id',
            'date' => 'sometimes|date',
            'status' => [
                'sometimes',
                Rule::in([
                    'requested',
                    'accepted',
                    'rejected',
                    'cancelled',
                    'rescheduled',
                ])
            ],
            'start_time' => 'sometimes|date_format:H:i:s',
            'updated_by' => 'required|integer|exists:users,id',
        ]);

        return response()->json($this->service->update($id, $validated));
    }

    // Se elimina una cita
    public function destroy(int $id)
    {
        $this->service->delete($id);
        return response()->json(null, 204);
    }
}
