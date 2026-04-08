<?php

namespace App\Http\Controllers;

use App\Services\CalendarService;
use Illuminate\Http\Request;

class CalendarController extends Controller
{
    // Se inyecta el servicio
    public function __construct(protected CalendarService $calendarService)
    {
    }

    // Se obtienen todas las citas de un doctor, con posibilidad de filtrarlas
    public function doctor(Request $request)
    {
        $request->validate([
            'client_id' => 'nullable|integer|exists:clients,id',
            'clinic_id' => 'nullable|integer|exists:clinics,id',
            'date_from' => 'nullable|date',
            'date_to' => 'nullable|date|after_or_equal:date_from',
        ]);

        $doctorID = $request->user()?->id;

        if (!$doctorID) {
            return response()->json(['error' => 'No se pudo identificar al usuario.'], 401);
        }

        $appointments = $this->calendarService->getDoctorCalendar(
            doctorId: $doctorID,
            clientId: $request->integer('client_id') ?: null,
            clinicId: $request->integer('clinic_id') ?: null,
            dateFrom: $request->input('date_from'),
            dateTo: $request->input('date_to'),
        );
        return response()->json($appointments);
    }

    // Se obtienen todas las citas que maneja una secretaria, con posibilidad de filtrarlas
    public function secretary(Request $request)
    {
        $request->validate([
            'doctor_id' => 'nullable|integer|exists:users,id',
            'clinic_id' => 'nullable|integer|exists:clinics,id',
            'date_from' => 'nullable|date',
            'date_to' => 'nullable|date|after_or_equal:date_from',
        ]);

        $secretaryID = $request->user()->id;

        $appointments = $this->calendarService->getSecretaryCalendar(
            secretaryId: $secretaryID,
            doctorId: $request->integer('doctor_id') ?: null,
            clinicId: $request->integer('clinic_id') ?: null,
            dateFrom: $request->input('date_from'),
            dateTo: $request->input('date_to'),
        );
        return response()->json($appointments);
    }

    // Se obtienen todas las citas de un paciente, con posibilidad de filtrarlas
    public function patient(Request $request)
    {
        $request->validate([
            'doctor_id' => 'nullable|integer|exists:users,id',
            'clinic_id' => 'nullable|integer|exists:clinics,id',
            'date_from' => 'nullable|date',
            'date_to' => 'nullable|date|after_or_equal:date_from',
        ]);

        $patientId = $request->user()->id;

        $appointments = $this->calendarService->getPatientCalendar(
            patientId: $patientId,
            doctorId: $request->integer('doctor_id') ?: null,
            clinicId: $request->integer('clinic_id') ?: null,
            dateFrom: $request->input('date_from'),
            dateTo: $request->input('date_to'),
        );
        return response()->json($appointments);
    }
}