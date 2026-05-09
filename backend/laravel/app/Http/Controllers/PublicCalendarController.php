<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\PublicCalendarService;

class PublicCalendarController extends Controller
{
    public function __construct(private PublicCalendarService $service)
    {
    }

    public function index(Request $request)
    {
        $filters = $request->validate([
            'doctor_id' => 'sometimes|integer|exists:users,id',
            'clinic_id' => 'sometimes|integer|exists:clinics,id',
            'date_from' => 'sometimes|date',
            'date_to' => 'sometimes|date|after_or_equal:date_from',
        ]);

        return response()->json(
            $this->service->getPublicCalendar($filters)
        );
    }
}