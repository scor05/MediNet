<?php

namespace App\Http\Controllers;

use App\Services\AppointmentService;
use Illuminate\Http\Request;

class PublicAppointmentController extends Controller
{
    public function __construct(private AppointmentService $service)
    {
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'id_schedule' => 'required|integer|exists:schedules,id',
            'id_patient'  => 'required|integer|exists:users,id',
            'date'        => 'required|date',
            'start_time'  => 'required|date_format:H:i',
        ]);

        $validated['status']     = 'requested';
        $validated['created_by'] = $request->user()->id;
        $validated['updated_by'] = $request->user()->id;

        return response()->json($this->service->create($validated), 201);
    }
}
