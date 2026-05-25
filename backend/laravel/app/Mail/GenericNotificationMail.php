<?php

namespace App\Mail;

use App\Models\User;
use Illuminate\Mail\Mailable;

class GenericNotificationMail extends Mailable
{
    public function __construct(
        public User $user,
        public string $notificationMessage
    ) {
    }

    public function build()
    {
        return $this->subject('Notificación de MediNet')
            ->view('emails.notification')
            ->with([
                'user' => $this->user,
                'message' => $this->notificationMessage,
            ]);
    }
}