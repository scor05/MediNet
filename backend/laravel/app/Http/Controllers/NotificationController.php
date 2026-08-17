<?php

namespace App\Http\Controllers;

use App\Services\NotificationService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class NotificationController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private NotificationService $service)
    {
    }

    // Se obtienen todas las notificaciones
    public function index()
    {
        return response()->json($this->service->getAll());
    }

    // Se obtiene una notificación por su id
    public function show(int $id)
    {
        return response()->json($this->service->getById($id));
    }

    // Se obtienen las notificaciones de un usuario
    public function indexByUser(int $userId)
    {
        return response()->json($this->service->getByUser($userId));
    }

    // Se crea una nueva notificación
    public function store(Request $request)
    {
        $validated = $request->validate([
            'id_user' => 'required|integer|exists:users,id',
            'type'    => ['required', Rule::in(['reminder', 'cancellation', 'reschedule', 'acceptance', 'rejection', 'waitlist_alert'])],
            'message' => 'required|string',
            'channel' => ['required', Rule::in(['email', 'sms', 'push', 'whatsapp'])],
        ]);

        return response()->json($this->service->create($validated), 201);
    }

    // Se elimina una notificación
    public function destroy(int $id)
    {
        $this->service->delete($id);
        return response()->json(null, 204);
    }
}
