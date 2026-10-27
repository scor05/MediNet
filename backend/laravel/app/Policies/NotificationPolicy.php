<?php

namespace App\Policies;

use App\Models\Notification;
use App\Models\User;

class NotificationPolicy
{
    public function viewAny(User $user): bool
    {
        return (bool) $user->is_active;
    }

    public function view(User $user, Notification $notification): bool
    {
        return (bool) $user->is_active
            && (int) $notification->id_user === (int) $user->id;
    }

    public function delete(User $user, Notification $notification): bool
    {
        return $this->view($user, $notification);
    }
}
