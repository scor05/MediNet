<?php

namespace App\Http\Controllers;

use App\Services\AppointmentService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\Rule;

class AppointmentController extends Controller
{
    public function __construct(
        protected AppointmentService $appointmentService
    ) {}

    public function index(): JsonResponse
    {
        $appointments = $this->appointmentService->index();

        return response()->json($appointments);
    }

    public function show(int $id): JsonResponse
    {
        $appointment = $this->appointmentService->show($id);

        if (!$appointment) {
            return response()->json([
                'message' => 'Cita no encontrada',
            ], 404);
        }

        return response()->json($appointment);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'id_schedule' => ['required', 'integer', 'exists:schedules,id'],
            'id_patient' => ['required', 'integer', 'exists:users,id'],
            'date' => ['required', 'date'],
            'status' => ['required', Rule::in([
                'requested',
                'accepted',
                'rejected',
                'cancelled',
                'rescheduled',
            ])],
            'start_time' => ['required', 'date_format:H:i:s'],
            'created_by' => ['required', 'integer', 'exists:users,id'],
            'updated_by' => ['required', 'integer', 'exists:users,id'],
        ]);

        $appointment = $this->appointmentService->store($validated);

        return response()->json($appointment, 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'id_schedule' => ['sometimes', 'integer', 'exists:schedules,id'],
            'id_patient' => ['sometimes', 'integer', 'exists:users,id'],
            'date' => ['sometimes', 'date'],
            'status' => ['sometimes', Rule::in([
                'requested',
                'accepted',
                'rejected',
                'cancelled',
                'rescheduled',
            ])],
            'start_time' => ['sometimes', 'date_format:H:i:s'],
            'updated_by' => ['required', 'integer', 'exists:users,id'],
        ]);

        $appointment = $this->appointmentService->update($id, $validated);

        if (!$appointment) {
            return response()->json([
                'message' => 'Cita no encontrada',
            ], 404);
        }

        return response()->json($appointment);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'updated_by' => ['required', 'integer', 'exists:users,id'],
        ]);

        $appointment = $this->appointmentService->cancel(
            $id,
            $validated['updated_by']
        );

        if (!$appointment) {
            return response()->json([
                'message' => 'Cita no encontrada',
            ], 404);
        }

        return response()->json([
            'message' => 'Cita cancelada correctamente',
            'appointment' => $appointment,
        ]);
    }
}
