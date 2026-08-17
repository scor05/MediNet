<?php
namespace App\Http\Controllers;
use App\Http\Requests\AvailableUsersRequest;
use App\Services\UserService;
use Illuminate\Http\Request;
class UserController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private UserService $service) {}
    // Se obtienen todos los usuarios
    public function index()
    {
        return response()->json($this->service->getAll());
    }
    // Se obtiene un usuario por su ID
    public function show($id)
    {
        if (! is_numeric($id)) {
            return response()->json(['error' => 'El ID debe ser un número.'], 400);
        }
        return response()->json($this->service->getById($id));
    }
    // Se actualiza un usuario
    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,'.$id,
            'phone' => 'sometimes|nullable|string|max:20',
            'is_active' => 'sometimes|boolean',
        ], [
            'email.unique' => 'Este correo ya está registrado.',
        ]);
        return response()->json($this->service->update($id, $validated));
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
    public function destroy($id)
    {
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
    // Se obtiene la información básica de un paciente (para secretarias autorizadas)
    public function patientInfo(Request $request, int $patientId)
    {
        $secretaryId = $request->user()->id;
        $patient = $this->service->getPatientBasicInfo($patientId, $secretaryId);
        if (!$patient) {
            return response()->json([
                'message' => 'No tienes permiso para ver este paciente.'
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
}