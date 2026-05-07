<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\PublicService;

class PublicController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private PublicService $service)
    {
    }

    // Se obtienen los doctores disponibles públicamente
    public function doctors(Request $request)
    {
        $validated = $request->validate([
            'clinic_id' => 'nullable|integer|exists:clinics,id',
        ]);

        return response()->json($this->service->getDoctors($validated['clinic_id'] ?? null));
    }

    // Se obtienen las clínicas disponibles públicamente
    public function clinics(Request $request)
    {
        $validated = $request->validate([
            'doctor_id' => 'nullable|integer|exists:users,id',
        ]);

        return response()->json($this->service->getClinics($validated['doctor_id'] ?? null));
    }

    // Se obtienen los slots disponibles para agendar una cita
    public function slots(Request $request)
    {
        $validated = $request->validate([
            'doctor_id' => 'required|integer|exists:users,id',
            'clinic_id' => 'required|integer|exists:clinics,id',
            'date' => 'required|date',
        ]);

        return response()->json($this->service->getSlots(
            doctorId: $validated['doctor_id'],
            clinicId: $validated['clinic_id'],
            date: $validated['date'],
        ));
    }
}
