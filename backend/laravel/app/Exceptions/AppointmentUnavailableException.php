<?php

namespace App\Exceptions;

use RuntimeException;

class AppointmentUnavailableException extends RuntimeException
{
    public const BLOCKED = 'Ese horario está bloqueado y no permite nuevas citas.';

    public const OCCUPIED = 'El horario seleccionado ya está ocupado.';
}
