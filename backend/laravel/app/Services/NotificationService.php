<?php

namespace App\Services;

use App\Repositories\NotificationRepository;
use App\Models\NotificationPreference;
use App\Models\User;
use Illuminate\Validation\ValidationException;

class NotificationService
{
    private const VALID_TYPES = [
        'reminder',
        'cancellation',
        'reschedule',
        'acceptance',
        'rejection',
    ];

    private const VALID_CHANNELS = [
        'email',
        'sms',
        'push',
    ];

    public function __construct(private NotificationRepository $repository)
    {
    }

    // Se obtienen todas las notificaciones
    public function getAll()
    {
        return $this->repository->findAll();
    }

    // Se obtienen las notificaciones de un usuario
    public function getByUser(int $userId)
    {
        return $this->repository->findByUser($userId);
    }

    // Se obtiene una notificación por su id
    public function getById(int $id)
    {
        return $this->repository->findById($id);
    }

    // Método central para despachar notificaciones según preferencias del usuario
    public function dispatch(string $type, int $userId, string $message)
    {
        if (!in_array($type, self::VALID_TYPES)) {
            throw ValidationException::withMessages([
                'type' => ['Tipo de notificación inválido.'],
            ]);
        }

        $user = User::findOrFail($userId);

        $channels = NotificationPreference::where('id_user', $userId)
            ->pluck('channel')
            ->toArray();

        if (empty($channels)) {
            $channels = ['email']; // canal por defecto si no hay preferencias
        }

        $sentNotifications = [];

        foreach ($channels as $channel) {
            if (!in_array($channel, self::VALID_CHANNELS)) {
                continue;
            }

            $this->sendToChannel($channel, $user, $message);

            $sentNotifications[] = $this->repository->create([
                'id_user' => $userId,
                'type' => $type,
                'message' => $message,
                'sent_at' => now(),
                'channel' => $channel,
            ]);
        }

        return $sentNotifications;
    }

    // Se mantiene create, pero ahora redirige al método central
    public function create(array $data)
    {
        return $this->dispatch(
            $data['type'],
            $data['id_user'],
            $data['message']
        );
    }

    // Se elimina una notificación
    public function delete(int $id)
    {
        $this->repository->delete($id);
    }

    // Despacha la notificación al canal correspondiente
    private function sendToChannel(string $channel, User $user, string $message): void
    {
        match ($channel) {
            'email' => $this->sendEmail($user, $message),
            'sms' => $this->sendSms($user, $message),
            'push' => $this->sendPush($user, $message),
            default => null,
        };
    }

    // Simulación de envío por email
    private function sendEmail(User $user, string $message): void
    {
        // Aquí luego se puede integrar Laravel Mail
    }

    // Simulación de envío por SMS
    private function sendSms(User $user, string $message): void
    {
        // Aquí luego se puede integrar Twilio u otro proveedor
    }

    // Simulación de envío push
    private function sendPush(User $user, string $message): void
    {
        // Aquí luego se puede integrar Firebase Cloud Messaging
    }
}
