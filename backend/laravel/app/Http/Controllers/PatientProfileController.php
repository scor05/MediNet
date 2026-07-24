<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\PatientProfileService;

class PatientProfileController extends Controller
{
    public function __construct(private PatientProfileService $service)
    {
    }

    public function show(Request $request)
    {
        $userId = $request->user()->id;
        return response()->json($this->service->getProfile($userId));
    }

    public function update(Request $request)
{
    $allowedFields = ['name', 'phone'];
    $receivedFields = array_keys($request->all());
    $invalidFields = array_diff($receivedFields, $allowedFields);

    if (!empty($invalidFields)) {
        return response()->json([
            'message' => 'Se enviaron campos que no pueden modificarse.',
            'errors' => [
                'fields' => [
                    'Campos no permitidos: ' . implode(', ', $invalidFields),
                ],
            ],
        ], 422);
    }

    $validated = $request->validate([
        'name' => 'sometimes|required|string|min:2|max:255',
        'phone' => 'sometimes|nullable|string|max:20',
    ], [
        'name.required' => 'El nombre es obligatorio cuando se envía.',
        'name.string' => 'El nombre debe ser una cadena de texto.',
        'name.min' => 'El nombre debe tener al menos 2 caracteres.',
        'name.max' => 'El nombre no debe exceder 255 caracteres.',
        'phone.string' => 'El teléfono debe ser una cadena de texto.',
        'phone.max' => 'El teléfono no debe exceder 20 caracteres.',
    ]);

    if (empty($validated)) {
        return response()->json([
            'message' => 'Debe enviar al menos un campo para actualizar.',
            'errors' => [
                'fields' => [
                    'Los campos permitidos son: name y phone.',
                ],
            ],
        ], 422);
    }

    $userId = $request->user()->id;

    return response()->json(
        $this->service->updateProfile($userId, $validated)
    );
}
}
