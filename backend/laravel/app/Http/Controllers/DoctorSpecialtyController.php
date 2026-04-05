<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\DoctorSpecialtyService;

class DoctorSpecialtyController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private DoctorSpecialtyService $service)
    {
    }

    // Se obtienen todas las especialidades de un doctor
    public function index($doctorId)
    {
        return response()->json($this->service->getByDoctor($doctorId));
    }

    // Se crea una nueva asignación de una especialidad a un doctor
    public function store(Request $request, $doctorId)
    {
        $validated = $request->validate([
            'id_specialty' => 'required|integer|exists:specialties,id',
        ]);
        return response()->json($this->service->create($doctorId, $validated), 201);
    }

    // Se elimina la asignación de una especialidad a un doctor
    public function destroy($doctorId, $specialtyId)
    {
        $this->service->delete($doctorId, $specialtyId);
        return response()->json(null, 204);
    }
}
