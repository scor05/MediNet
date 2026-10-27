<?php

namespace App\Http\Controllers;

use App\Models\Waitlist;
use App\Services\BackupAppointmentService;
use App\Services\WaitlistService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

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
        $waitlist = $this->findOrFail($id);
        Gate::forUser($request->user())->authorize('participate', $waitlist);

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
        $waitlist = $this->findOrFail($id);
        Gate::forUser($request->user())->authorize('participate', $waitlist);

        $waitlist = $this->backupService->decline(
            $id,
            $request->user()->id,
        );

        return response()->json(['data' => $waitlist]);
    }

    public function index(Request $request)
    {
        Gate::forUser($request->user())->authorize(
            'viewAny',
            Waitlist::class,
        );

        return response()->json(
            $this->service->getVisibleTo((int) $request->user()->id)
        );
    }

    public function show(Request $request, int $id)
    {
        $waitlist = $this->findOrFail($id);
        Gate::forUser($request->user())->authorize('view', $waitlist);

        return response()->json($waitlist);
    }

    public function indexMine(Request $request)
    {
        return response()->json(
            $this->service->getByPatient((int) $request->user()->id)
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
        $waitlist = $this->findOrFail((int) $id);

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

        $isCancellation = ($data['status'] ?? null) === 'cancelled'
            && count($data) === 1;

        Gate::forUser($request->user())->authorize(
            $isCancellation ? 'cancel' : 'update',
            $waitlist,
        );

        if ($isCancellation && (int) $waitlist->id_patient === (int) $request->user()->id) {
            $waitlist = $this->backupService->cancelWaitlist(
                (int) $id,
                (int) $request->user()->id,
            );
        } else {
            $waitlist = $this->service->update((int) $id, $data);
        }

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

    public function destroy(Request $request, int $id)
    {
        $waitlist = $this->findOrFail($id);
        Gate::forUser($request->user())->authorize('delete', $waitlist);

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

    private function findOrFail(int $id): Waitlist
    {
        $waitlist = $this->service->getById($id);

        abort_if($waitlist === null, 404, 'Registro no encontrado');

        return $waitlist;
    }
}
