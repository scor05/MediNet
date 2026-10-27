<?php

namespace App\Http\Controllers;

use App\Models\Appointment;
use App\Models\Schedule;
use App\Services\AppointmentService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class AppointmentController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private AppointmentService $service) {}

    // Se obtienen todas las citas
    public function index(Request $request)
    {
        Gate::forUser($request->user())->authorize('viewAny', Appointment::class);

        return response()->json(
            $this->service->getAllVisibleTo((int) $request->user()->id)
        );
    }

    // Se obtiene una cita por su id
    public function show(Request $request, int $id)
    {
        $appointment = $this->service->getById($id);
        Gate::forUser($request->user())->authorize('view', $appointment);

        return response()->json($appointment);
    }

    // Se crea una nueva cita
    public function store(Request $request)
    {
        $validated = $request->validate([
            'id_schedule' => 'required|integer|exists:schedules,id',
            'id_patient' => 'nullable|integer|exists:users,id',
            'name_patient' => 'required_without:id_patient|string|nullable',
            'date' => 'required|date_format:Y-m-d',
            'start_time' => 'required|date_format:H:i',
        ], [
            'name_patient.required_without' => 'Debe ingresar el nombre del paciente cuando no seleccione un paciente existente.',
        ]);

        $schedule = Schedule::findOrFail($validated['id_schedule']);
        Gate::forUser($request->user())->authorize(
            'create',
            [Appointment::class, $schedule],
        );

        $actorId = (int) $request->user()->id;
        $validated['status'] = 'accepted';
        $validated['created_by'] = $actorId;
        $validated['updated_by'] = $actorId;

        return response()->json($this->service->create($validated), 201);
    }

    // Se actualiza una cita
    public function update(Request $request, int $id)
    {
        $validated = $request->validate([
            'id_patient' => 'sometimes|integer|exists:users,id',
            'name_patient' => 'sometimes|string',
            'date' => 'sometimes|date_format:Y-m-d',
            'status' => ['sometimes', Rule::in(['cancelled'])],
            'start_time' => 'sometimes|date_format:H:i',
        ]);

        if ($validated === []) {
            throw ValidationException::withMessages([
                'appointment' => ['No se proporcionaron cambios válidos.'],
            ]);
        }

        $appointment = $this->service->getById($id);
        $changesAppointmentData = array_intersect_key($validated, array_flip([
            'id_patient',
            'name_patient',
            'date',
            'start_time',
        ])) !== [];

        if ($changesAppointmentData) {
            Gate::forUser($request->user())->authorize('update', $appointment);
        }

        if (array_key_exists('status', $validated)) {
            Gate::forUser($request->user())->authorize('cancel', $appointment);
        }

        $validated['updated_by'] = (int) $request->user()->id;

        return response()->json($this->service->update($id, $validated));
    }

    public function decide(Request $request, int $id)
    {
        $validated = $request->validate([
            'decision' => ['required', Rule::in(['accept', 'reject'])],
        ]);

        $appointment = $this->service->getById($id);
        Gate::forUser($request->user())->authorize('decide', $appointment);

        return response()->json($this->service->decide(
            $id,
            $validated['decision'],
            $request->user()->id,
        ));
    }

    public function checkReschedule(Request $request, int $id)
    {
        $validated = $request->validate([
            'date' => 'required|date_format:Y-m-d',
            'start_time' => 'required|date_format:H:i',
        ]);

        $appointment = $this->service->getById($id);
        Gate::forUser($request->user())->authorize('reschedule', $appointment);

        $this->service->checkReschedule(
            $id,
            $validated['date'],
            $validated['start_time'],
        );

        return response()->json(['available' => true]);
    }

    public function reschedule(Request $request, int $id)
    {
        $validated = $request->validate([
            'date' => 'required|date_format:Y-m-d',
            'start_time' => 'required|date_format:H:i',
        ]);

        $appointment = $this->service->getById($id);
        Gate::forUser($request->user())->authorize('reschedule', $appointment);

        return response()->json($this->service->reschedule(
            $id,
            $validated['date'],
            $validated['start_time'],
            $request->user()->id,
        ));
    }

    // Se elimina una cita
    public function destroy(Request $request, int $id)
    {
        $appointment = $this->service->getById($id);
        Gate::forUser($request->user())->authorize('delete', $appointment);

        $this->service->delete($id);

        return response()->json(null, 204);
    }
}
