<?php

namespace App\Repositories;

use App\Models\Superadmin;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class UserRepository
{
    // Se obtienen todos los usuarios
    public function findAll()
    {
        return User::all();
    }

    // Se obtiene un usuario por su ID
    public function findById($id)
    {
        return User::findOrFail($id);
    }

    // Se crea un nuevo usuario
    public function create($data)
    {
        return User::create($data);
    }

    // Se actualiza un usuario
    public function update($id, $data)
    {
        $user = User::findOrFail($id);
        $user->update($data);

        return $user;
    }

    // Se guarda el token FCM del usuario
    public function updateFcmToken(int $id, string $fcmToken)
    {
        $user = User::findOrFail($id);
        $user->update(['fcm_token' => $fcmToken]);

        return $user;
    }

    // Se elimina un usuario
    public function delete($id)
    {
        $user = User::findOrFail($id);
        $user->delete();
    }

    // Retorna el client_id al que pertenece un usuario.
    public function getClientIdForUser(int $userId): ?int
    {
        $client = DB::table('client_users')
            ->where('id_user', $userId)
            ->where('is_active', true)
            ->first(['id_client']);

        return $client?->id_client;
    }

    // Se obtiene información básica del usuario
    public function getProfile($id)
    {
        $user = User::with([
            'clientUsers.client',
        ])->findOrFail($id);

        $memberships = $user->clientUsers->map(function ($clientUser) {
            return [
                'client_id' => $clientUser->id_client,
                'client_name' => $clientUser->client?->name,
                'role' => $clientUser->role,
                'role_name' => $this->_mapRole($clientUser->role),
                'is_admin' => $clientUser->is_admin,
                'is_active' => $clientUser->is_active,
            ];
        })->values();

        $activeMemberships = $memberships->where('is_active', true)->values();

        $isDoctor = $activeMemberships->contains('role_name', 'doctor');

        $isSecretary = $activeMemberships->contains('role_name', 'secretary');

        $secretaryClientIds = $activeMemberships
            ->where('role_name', 'secretary')
            ->pluck('client_id')
            ->unique()
            ->values();

        $adminOf = $activeMemberships
            ->where('is_admin', true)
            ->map(function ($membership) {
                return [
                    'client_id' => $membership['client_id'],
                    'client_name' => $membership['client_name'],
                ];
            })
            ->unique('client_id')
            ->values();

        $superadmin = Superadmin::where('id_user', $id)->exists();

        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'is_active' => $user->is_active,
            'is_doctor' => $isDoctor,
            'is_secretary' => $isSecretary,
            'secretary_client_ids' => $secretaryClientIds,
            'admin_of' => $adminOf,
            'superadmin' => $superadmin,
        ];
    }

    // Se obtiene los usuarios que no están asociados ya al cliente y que no son superadmins
    public function findAvailableForClient(int $clientId, string $search)
    {
        return User::whereNotIn('id', function ($query) use ($clientId) {
            $query->select('id_user')
                ->from('client_users')
                ->where('id_client', $clientId);
        })
            ->whereNotIn('id', function ($query) {
                $query->select('id_user')
                    ->from('superadmins');
            })
            ->when($search, function ($query, $search) {
                $query->where(function ($q) use ($search) {
                    $q->where('name', 'ilike', "%{$search}%")
                        ->orWhere('email', 'ilike', "%{$search}%");
                });
            })
            ->select('id', 'name', 'email')
            ->orderBy('name')
            ->limit(8)
            ->get()
            ->toArray();
    }

    // Se obtiene todos los usuarios que no son superadmins
    public function findAvailable(string $search)
    {
        return User::whereNotIn('id', function ($query) {
            $query->select('id_user')
                ->from('superadmins');
        })
            ->when($search, function ($query, $search) {
                $query->where(function ($q) use ($search) {
                    $q->where('name', 'ilike', "%{$search}%")
                        ->orWhere('email', 'ilike', "%{$search}%");
                });
            })
            ->select('id', 'name', 'email')
            ->orderBy('name')
            ->limit(8)
            ->get()
            ->toArray();
    }

    // Busca cuentas activas que pueden vincularse como pacientes a una cita.
    public function searchPatients(string $search)
    {
        return User::where('is_active', true)
            ->whereNotIn('id', function ($query) {
                $query->select('id_user')
                    ->from('superadmins');
            })
            ->when($search !== '', function ($query) use ($search) {
                $query->where(function ($patientQuery) use ($search) {
                    $patientQuery->where('name', 'ilike', "%{$search}%")
                        ->orWhere('email', 'ilike', "%{$search}%");
                });
            })
            ->when(
                $search === '',
                fn ($query) => $query->inRandomOrder(),
                fn ($query) => $query->orderBy('name')
            )
            ->select('id', 'name', 'email')
            ->limit(16)
            ->get()
            ->toArray();
    }

    /*
    PATIENT INFO (para doctores y secretarias autorizados)
    */

    // El doctor puede consultar pacientes que tengan una cita con él. Una
    // secretaria puede consultar pacientes con citas dentro de su organización.
    public function getPatientBasicInfo(int $patientId, int $requesterId)
    {
        $hasAccess = DB::table('appointments')
            ->join('schedules', 'schedules.id', '=', 'appointments.id_schedule')
            ->join('clinics', 'clinics.id', '=', 'schedules.id_clinic')
            ->where('appointments.id_patient', $patientId)
            ->where(function ($query) use ($requesterId) {
                $query->where('schedules.id_doctor', $requesterId)
                    ->orWhereExists(function ($membership) use ($requesterId) {
                        $membership->selectRaw('1')
                            ->from('client_users AS cu')
                            ->whereColumn('cu.id_client', 'clinics.id_client')
                            ->where('cu.id_user', $requesterId)
                            ->where('cu.role', 2)
                            ->where('cu.is_active', true);
                    });
            })
            ->exists();

        if (! $hasAccess) {
            return null;
        }

        $user = User::select('id', 'name', 'email', 'phone')
            ->find($patientId);

        return $user;
    }

    /*
    HELPERS
    */
    private function _mapRole(int $role): string
    {
        return match ($role) {
            0 => 'admin',
            1 => 'doctor',
            2 => 'secretary',
            default => 'Unknown',
        };
    }
}
