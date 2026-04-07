<?php

namespace App\Http\Controllers;

use App\Services\CalendarService;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Http\JsonResponse;

class CalendarController extends Controller
{
    public function __construct(protected CalendarService $calendarService)
    {
    }

    /** ENDPOINT para que el doctor vea el calendario
     * GET /api/calendar/doctor
     */
    public function doctor(Request $request): JsonResponse
    {
        $request->validate([
            'client_id' => 'nullable|integer|exists:clients,id',
            'clinic_id' => 'nullable|integer|exists:clinics,id',
            'date_from' => 'nullable|date',
            'date_to' => 'nullable|date|after_or_equal:date_from',
        ]);

        $doctorID = $request->user()->id;

        $appointments = $this->calendarService->getDoctorCalendar(
            doctorId: $doctorID,
            clientId: $request->integer('client_id') ?: null,
            clinicId: $request->integer('clinic_id') ?: null,
            dateFrom: $request->input('date_from'),
            dateTo: $request->input('date_to'),
        );
        return response()->json($appointments);
    }

    /**GET para que la secretaria vea el calendario
     * GET /api/calendar/secretary
     *  puede usar filtros opcionales como doctor_id, client_id, clinic_id, date_from, date_to
     */
    public function secretary(Request $request): JsonResponse
    {
        $request->validate([
            'doctor_id' => 'nullable|integer|exists:users,id',
            'clinic_id' => 'nullable|integer|exists:clinics,id',
            'date_from' => 'nullable|date',
            'date_to' => 'nullable|date|after_or_equal:date_from',
        ]);

        $appointments = $this->calendarService->getSecretaryCalendar(
            secretaryId: $request->user()->id,
            doctorId: $request->integer('doctor_id') ?: null,
            clinicId: $request->integer('clinic_id') ?: null,
            dateFrom: $request->input('date_from'),
            dateTo: $request->input('date_to'),
        );
        return response()->json($appointments);
    }

    /** ENDPOINT para que los pacientes puedan ver el calendario de citas
     * GET /api/calendar/patient
     *  puede usar filtros opcionales como doctor_id, clinic_id, date_from, date_to
     * al menos doctor_id o clinic_id son requeridos
     */
    public function patient(Request $request): JsonResponse
    {
        $request->validate([
            'doctor_id' => 'nullable|integer|exists:users,id',
            'clinic_id' => 'nullable|integer|exists:clinics,id',
            'date_from' => 'nullable|date',
            'date_to' => 'nullable|date|after_or_equal:date_from',
        ]);

        if (!$request->filled('doctor_id') && !$request->filled('clinic_id')) {
            return response()->json(['message' => 'Al menos doctor_id o clinic_id son requeridos'], 422);
        }
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