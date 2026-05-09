<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\PublicSlotService;

class PublicSlotController extends Controller
{
    public function __construct(private PublicSlotService $service)
    {
    }

    public function index(Request $request)
    {
        $filters = $request->validate([
            'doctor_id' => 'required|integer|exists:users,id',
            'clinic_id' => 'required|integer|exists:clinics,id',
            'date' => 'required|date',
        ]);

        return response()->json(
            $this->service->getAvailableSlots($filters)
        );
    }
}