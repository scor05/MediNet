<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\ScheduleService;

class ScheduleController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private ScheduleService $service)
    {
    }

    // Se obtienen todos los horarios
    public function index()
    {
        return response()->json($this->service->getAll());
    }

    // Se obtiene un horario por su ID
    public function show($id)
    {
        return response()->json($this->service->getById($id));
    }

    // Se obtienen los horarios de un doctor
    public function indexByDoctor($doctorId)
    {
        return response()->json($this->service->getByDoctor($doctorId));
    }

    // Se crea un nuevo horario
    public function store(Request $request)
    {
        $validated = $request->validate([
            'id_doctor'   => 'required|integer|exists:users,id',
            'id_clinic'   => 'required|integer|exists:clinics,id',
            'day_of_week' => 'required|integer|between:0,6',
            'start_time'  => 'required|date_format:H:i',
            'end_time'    => 'required|date_format:H:i|after:start_time',
            'duration'    => 'required|integer|min:1',
            'is_active'   => 'sometimes|boolean',
        ]);

        return response()->json($this->service->create($validated), 201);
    }

    // Se actualiza un horario
    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'day_of_week' => 'sometimes|integer|between:0,6',
            'start_time'  => 'sometimes|date_format:H:i',
            'end_time'    => 'sometimes|date_format:H:i|after:start_time',
            'duration'    => 'sometimes|integer|min:1',
            'is_active'   => 'sometimes|boolean',
        ]);

        return response()->json($this->service->update($id, $validated));
    }

    // Se elimina un horario
    public function destroy($id)
    {
        $this->service->delete($id);
        return response()->json(null, 204);
    }
}