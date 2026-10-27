<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use App\Services\NotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class NotificationController extends Controller
{
    public function __construct(private NotificationService $service)
    {
    }

    public function index(Request $request)
    {
        Gate::forUser($request->user())->authorize('viewAny', Notification::class);

        return response()->json(
            $this->service->getByUser((int) $request->user()->id)
        );
    }

    public function show(Request $request, int $id)
    {
        $notification = $this->service->getById($id);
        Gate::forUser($request->user())->authorize('view', $notification);

        return response()->json($notification);
    }

    public function destroy(Request $request, int $id)
    {
        $notification = $this->service->getById($id);
        Gate::forUser($request->user())->authorize('delete', $notification);

        $this->service->delete($id);

        return response()->json(null, 204);
    }
}
