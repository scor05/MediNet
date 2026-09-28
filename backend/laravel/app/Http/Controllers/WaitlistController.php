<?php

namespace App\Http\Controllers;

use App\Services\BackupAppointmentService;
use App\Services\WaitlistService;
use Illuminate\Http\Request;

class WaitlistController extends Controller
{
    protected WaitlistService $service;

    public function __construct(
        WaitlistService $service,
        private BackupAppointmentService $backupService,
    ) {
        $this->service = $service;
    }

    public function storeBackup(Request $request, int $id)
    {
        $data = $request->validate([
            'id_schedule' => 'required|integer|exists:schedules,id',
            'date' => 'required|date_format:Y-m-d',
            'start_time' => 'required|date_format:H:i',
        ]);

        $appointment = $this->backupService->create(
            $id,
            $request->user()->id,
            $data,
        );

        return response()->json(['data' => $appointment], 201);
    }

    public function declineBackup(Request $request, int $id)
    {
        $waitlist = $this->backupService->decline(
            $id,
            $request->user()->id,
        );

        return response()->json(['data' => $waitlist]);
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

        if (! $waitlist) {
            return response()->json([
                'message' => 'Registro no encontrado',
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
            'id_target_appointment' => [
                'nullable',
                'exists:appointments,id',
            ],

            'id_schedule' => [
                'required_without:id_target_appointment',
                'integer',
                'exists:schedules,id',
            ],

            'date' => [
                'required_without:id_target_appointment',
                'date_format:Y-m-d',
            ],

            'start_time' => [
                'required_without:id_target_appointment',
                'date_format:H:i',
            ],

            'id_fallback_appointment' => [
                'nullable',
                'exists:appointments,id',
                'different:id_target_appointment',
            ],
        ]);
        $data['id_patient'] = $request->user()->id;

        $waitlist = $this->service->join($data);

        return response()->json([
            'message' => 'Paciente agregado a la lista de espera',
            'data' => $waitlist,
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $data = $request->validate([
            'status' => [
                'sometimes',
                'in:waiting,notified,fulfilled,cancelled',
            ],

            'id_fallback_appointment' => [
                'nullable',
                'exists:appointments,id',
            ],
        ]);

        $waitlist = ($data['status'] ?? null) === 'cancelled'
            ? $this->backupService->cancelWaitlist(
                (int) $id,
                $request->user()->id,
            )
            : $this->service->update($id, $data);

        if (! $waitlist) {
            return response()->json([
                'message' => 'Registro no encontrado',
            ], 404);
        }

        return response()->json([
            'message' => 'Lista de espera actualizada',
            'data' => $waitlist,
        ]);
    }

    public function destroy($id)
    {
        $deleted = $this->service->leave($id);

        if (! $deleted) {
            return response()->json([
                'message' => 'Registro no encontrado',
            ], 404);
        }

        return response()->json([
            'message' => 'Paciente eliminado de la lista de espera',
        ]);
    }
}
