<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\ClinicService;

class ClinicController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private ClinicService $service)
    {
    }

    // Se obtienen todas las clínicas
    public function index()
    {
        return response()->json($this->service->getAll());
    }

    // Se obtiene una clínica por su ID
    public function show($id)
    {
        return response()->json($this->service->getById($id));
    }

    // Se crea una nueva clínica
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'    => 'required|string|max:255',
            'address' => 'required|string',
            'phone'   => 'required|string|unique:clinics,phone',
            'email'   => 'required|email|unique:clinics,email',
        ]);

        return response()->json($this->service->create($validated), 201);
    }

    // Se actualiza una clínica
    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'name'    => 'string|max:255',
            'address' => 'string',
            'phone'   => 'string|unique:clinics,phone,' . $id,
            'email'   => 'email|unique:clinics,email,' . $id,
        ]);

        return response()->json($this->service->update($id, $validated));
    }

    // Se elimina una clínica
    public function destroy($id)
    {
        $this->service->delete($id);
        return response()->json(null, 204);
    }
}