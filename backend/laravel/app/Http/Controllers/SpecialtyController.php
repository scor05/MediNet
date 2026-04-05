<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\SpecialtyService;

class SpecialtyController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private SpecialtyService $service)
    {
    }

    // Se obtienen todas las especialidades
    public function index()
    {
        return response()->json($this->service->getAll());
    }

    // Se obtiene una especialidad por su id
    public function show($id)
    {
        return response()->json($this->service->getById($id));
    }

    // Se crea una nueva especialidad
    public function store(Request $request)
    {
        $validated = $request->validate([
            'specialty' => 'required|string|max:255',
        ]);
        return response()->json($this->service->create($validated), 201);
    }

    // Se actualiza una especialidad
    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'specialty' => 'string|max:255',
        ]);
        return response()->json($this->service->update($id, $validated));
    }

    // Se elimina una especialidad
    public function destroy($id)
    {
        $this->service->delete($id);
        return response()->json(null, 204);
    }
}
