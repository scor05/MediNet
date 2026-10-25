<?php

namespace App\Http\Controllers;

use App\Http\Requests\AvailableUsersRequest;
use App\Models\User;
use App\Services\UserService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class UserController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private UserService $service) {}

    // Se obtienen todos los usuarios
    public function index(Request $request)
    {
        Gate::forUser($request->user())->authorize('viewAny', User::class);

        return response()->json($this->service->getAllVisibleTo($request->user()));
    }

    // Se obtiene un usuario por su ID
    public function show(Request $request, int $id)
    {
        $user = $this->service->getById($id);
        Gate::forUser($request->user())->authorize('view', $user);

        return response()->json($this->safeUserData($user));
    }

    // Se actualiza un usuario
    public function update(Request $request, int $id)
    {
        $user = $this->service->getById($id);
        Gate::forUser($request->user())->authorize('update', $user);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,'.$id,
            'phone' => 'sometimes|nullable|string|max:20',
            'is_active' => 'sometimes|boolean',
        ], [
            'email.unique' => 'Este correo ya está registrado.',
        ]);

        if (array_intersect_key($validated, array_flip(['email', 'is_active'])) !== []) {
            Gate::forUser($request->user())->authorize('updateSensitive', $user);
        }

        $updatedUser = $this->service->update($id, $validated);

        return response()->json($this->safeUserData($updatedUser));
    }

    // Se guarda el token FCM del usuario
    public function saveFcmToken(Request $request)
    {
        $validated = $request->validate([
            'fcm_token' => 'required|string',
        ]);

        return response()->json(
            $this->service->updateFcmToken(
                $request->user()->id,
                $validated['fcm_token']
            )
        );
    }

    // Se elimina un usuario
    public function destroy(Request $request, int $id)
    {
        $user = $this->service->getById($id);
        Gate::forUser($request->user())->authorize('delete', $user);

        $this->service->delete($id);

        return response()->json(null, 204);
    }

    // Se obtiene información básica del usuario
    public function profile(Request $request)
    {
        return response()->json(
            $this->service->getProfile($request->user()->id)
        );
    }

    // Se obtiene los usuarios que no están asociados ya al cliente y que no son superadmins
    public function availableForClient(AvailableUsersRequest $request, int $clientId)
    {
        $users = $this->service->getAvailableForClient(
            clientId: $clientId,
            search: $request->validated('search', ''),
        );

        return response()->json($users);
    }

    // Se obtienen todos los usuarios que no son superadmins
    public function available(AvailableUsersRequest $request)
    {
        $users = $this->service->getAvailable(
            search: $request->validated('search', ''),
        );

        return response()->json($users);
    }

    // Se obtiene la información básica de un paciente para personal autorizado.
    public function patientInfo(Request $request, int $patientId)
    {
        $requesterId = $request->user()->id;
        $patient = $this->service->getPatientBasicInfo($patientId, $requesterId);
        if (! $patient) {
            return response()->json([
                'message' => 'No tienes permiso para ver este paciente.',
            ], 403);
        }

        return response()->json($patient);
    }

    public function patients(AvailableUsersRequest $request)
    {
        return response()->json(
            $this->service->searchPatients(
                trim($request->validated('search', ''))
            )
        );
    }

    private function safeUserData(User $user): array
    {
        return $user->only([
            'id',
            'name',
            'email',
            'phone',
            'is_active',
        ]);
    }
}
