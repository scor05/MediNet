<?php

namespace App\Http\Controllers;

use App\Services\NotificationPreferenceService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class NotificationPreferenceController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private NotificationPreferenceService $service)
    {
    }

    // Se obtienen las preferencias de notificación de un usuario
    public function index(int $userId)
    {
        return response()->json($this->service->getByUser($userId));
    }

    // Se actualizan las preferencias de notificación de un usuario
    public function update(Request $request, int $userId)
    {
        $validated = $request->validate([
            'channels'   => 'required|array',
            'channels.*' => ['required', Rule::in(['email', 'sms', 'push', 'whatsapp'])],
        ]);

        return response()->json($this->service->updatePreferences($userId, $validated['channels']));
    }

    // Se eliminan las preferencias de notificación de un usuario
    public function destroy(int $userId)
    {
        $this->service->deleteByUser($userId);
        return response()->json(null, 204);
    }
}
