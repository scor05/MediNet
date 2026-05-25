<?php

namespace App\Http\Controllers;

use App\Services\ScheduleBlockadeService;
use Illuminate\Http\Request;

class ScheduleBlockadeController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private ScheduleBlockadeService $service)
    {
    }

    // GET /schedule-blockades?schedule_id=&date=
    // Se obtienen los bloqueos de un schedule en una fecha
    public function index(Request $request)
    {
        $request->validate([
            'schedule_id' => 'required|integer|exists:schedules,id',
            'date'        => 'required|date',
        ]);

        return response()->json(
            $this->service->getByScheduleAndDate(
                $request->integer('schedule_id'),
                $request->input('date')
            )
        );
    }

    // POST /schedule-blockades
    // Se crea un nuevo bloqueo
    public function store(Request $request)
    {
        $validated = $request->validate([
            'id_schedule' => 'required|integer|exists:schedules,id',
            'date'        => 'required|date',
            'start_time'  => 'required|date_format:H:i',
            'end_time'    => 'required|date_format:H:i|after:start_time',
        ]);

        return response()->json($this->service->create($validated), 201);
    }

    // DELETE /schedule-blockades/{id}
    // Se elimina un bloqueo
    public function destroy(int $id)
    {
        $this->service->delete($id);
        return response()->json(null, 204);
    }
}
