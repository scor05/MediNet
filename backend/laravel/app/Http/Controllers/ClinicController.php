<?php

namespace App\Http\Controllers;

use App\Models\Superadmin;
use App\Services\ClinicService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ClinicController extends Controller
{
    // Se inyecta el servicio
    public function __construct(private ClinicService $service) {}

    // Se obtienen todas las clínicas
    public function index(Request $request)
    {
        return response()->json($this->service->getForUser($request->user()->id));
    }

    // Se obtienen todas las clínicas de un cliente
    public function indexByClient(Request $request, int $clientId)
    {
        $this->authorizeClientAccess($request, $clientId);

        return response()->json($this->service->getByClient($clientId));
    }

    // Se obtiene una clínica por su ID
    public function show(Request $request, int $id)
    {
        $clinic = $this->service->getById($id);
        $this->authorizeClientAccess($request, $clinic->id_client);

        return response()->json($clinic);
    }

    // Se crea una nueva clínica
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'address' => 'required|string',
            'phone' => 'required|string|unique:clinics,phone',
            'email' => 'required|email|unique:clinics,email',
            'id_client' => 'required|exists:clients,id',
        ], [
            'phone.unique' => 'El teléfono ya es usado por otra clínica',
            'email.unique' => 'El correo ya es usado por otra clínica',
        ]);

        $this->authorizeClientAccess($request, $validated['id_client'], write: true);

        return response()->json($this->service->create($validated), 201);
    }

    // Se actualiza una clínica
    public function update(Request $request, int $id)
    {
        $clinic = $this->service->getById($id);
        $this->authorizeClientAccess($request, $clinic->id_client, write: true);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'address' => 'sometimes|string',
            'phone' => 'sometimes|string|unique:clinics,phone,'.$id,
            'email' => 'sometimes|email|unique:clinics,email,'.$id,
            'is_active' => 'sometimes|boolean',
        ], [
            'phone.unique' => 'El teléfono ya es usado por otra clínica',
            'email.unique' => 'El correo ya es usado por otra clínica',
        ]);

        return response()->json($this->service->update($id, $validated));
    }

    // Se elimina una clínica
    public function destroy(Request $request, int $id)
    {
        $clinic = $this->service->getById($id);
        $this->authorizeClientAccess($request, $clinic->id_client, write: true);
        $this->service->delete($id);

        return response()->json(null, 204);
    }

    private function authorizeClientAccess(
        Request $request,
        int $clientId,
        bool $write = false,
    ): void {
        $userId = $request->user()->id;
        if (Superadmin::where('id_user', $userId)->exists()) {
            return;
        }

        $hasAccess = DB::table('client_users')
            ->where('id_user', $userId)
            ->where('id_client', $clientId)
            ->where('is_active', true)
            ->when($write, fn ($query) => $query->where('is_admin', true))
            ->exists();

        abort_unless(
            $hasAccess,
            403,
            'No tienes acceso a las clínicas de esta organización.',
        );
    }
}
