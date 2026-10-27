<?php

namespace App\Http\Controllers;

use App\Services\NotificationPreferenceService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class NotificationPreferenceController extends Controller
{
    public function __construct(private NotificationPreferenceService $service)
    {
    }

    public function index(Request $request)
    {
        return response()->json(
            $this->service->getByUser((int) $request->user()->id)
        );
    }

    public function update(Request $request)
    {
        $validated = $request->validate([
            'channels' => 'required|array',
            'channels.*' => [
                'required',
                Rule::in(['email', 'sms', 'push', 'whatsapp']),
            ],
        ]);

        return response()->json($this->service->updatePreferences(
            (int) $request->user()->id,
            $validated['channels'],
        ));
    }

    public function destroy(Request $request)
    {
        $this->service->deleteByUser((int) $request->user()->id);

        return response()->json(null, 204);
    }
}
