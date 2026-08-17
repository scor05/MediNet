<?php

namespace App\Http\Controllers;

use App\Services\WaitlistService;
use Illuminate\Http\Request;

class WaitlistController extends Controller
{
    protected WaitlistService $service;

    public function __construct(
        WaitlistService $service
    ) {
        $this->service = $service;
    }

    public function index()
    {
        return response()->json(
            $this->service->getAll()
        );
    }

    public function show($id)
    {
        $waitlist = $this->service->getById($id);

        if (!$waitlist) {
            return response()->json([
                'message' => 'Registro no encontrado'
            ], 404);
        }

        return response()->json($waitlist);
    }

    public function indexByPatient($patientId)
    {
        return response()->json(
            $this->service->getByPatient($patientId)
        );
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'id_patient' => [
                'required',
                'exists:patients,id'
            ],

            'id_target_appointment' => [
                'required',
                'exists:appointments,id'
            ],

            'id_fallback_appointment' => [
                'nullable',
                'exists:appointments,id',
                'different:id_target_appointment'
            ],
        ]);

        $waitlist = $this->service->join($data);

        return response()->json([
            'message' =>
                'Paciente agregado a la lista de espera',
            'data' => $waitlist
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $data = $request->validate([
            'status' => [
                'sometimes',
                'in:waiting,notified,cancelled'
            ],

            'id_fallback_appointment' => [
                'nullable',
                'exists:appointments,id'
            ]
        ]);

        $waitlist =
            $this->service->update($id, $data);

        if (!$waitlist) {
            return response()->json([
                'message' => 'Registro no encontrado'
            ], 404);
        }

        return response()->json([
            'message' => 'Lista de espera actualizada',
            'data' => $waitlist
        ]);
    }

    public function destroy($id)
    {
        $deleted = $this->service->leave($id);

        if (!$deleted) {
            return response()->json([
                'message' => 'Registro no encontrado'
            ], 404);
        }

        return response()->json([
            'message' =>
                'Paciente eliminado de la lista de espera'
        ]);
    }
}
