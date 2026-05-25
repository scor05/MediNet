<?php

namespace App\Services\Notifications;

use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Validation\ValidationException;

class WhatsAppNotificationChannel
{
    public function send(User $user, string $message): void
    {
        if (blank($user->phone)) {
            throw ValidationException::withMessages([
                'phone' => ['El usuario no tiene telefono registrado para recibir WhatsApp.'],
            ]);
        }

        $sid = config('services.whatsapp.twilio.account_sid');
        $token = config('services.whatsapp.twilio.auth_token');
        $from = config('services.whatsapp.twilio.from');

        if (!$sid || !$token || !$from) {
            return;
        }

        Http::asForm()
            ->withBasicAuth($sid, $token)
            ->post("https://api.twilio.com/2010-04-01/Accounts/{$sid}/Messages.json", [
                'From' => $this->formatNumber($from),
                'To' => $this->formatNumber($user->phone),
                'Body' => $message,
            ])
            ->throw();
    }

    private function formatNumber(string $phone): string
    {
        $phone = trim($phone);

        if (str_starts_with($phone, 'whatsapp:')) {
            return $phone;
        }

        return 'whatsapp:' . preg_replace('/[^\d+]/', '', $phone);
    }
}