<?php

namespace App\Exceptions;

use RuntimeException;

class AppointmentUnavailableException extends RuntimeException
{
    public const BLOCKED = 'Ese horario está bloqueado y no permite nuevas citas.';

    public const OCCUPIED = 'El horario seleccionado ya está ocupado.';

    public const INVALID_SCHEDULE = 'El doctor no tiene un horario válido en la fecha y hora seleccionadas.';

    public const PAST = 'No se puede reprogramar una cita a una fecha u hora pasada.';

    public const UNCHANGED = 'Selecciona una fecha u hora diferente para reprogramar la cita.';

    public const NOT_ACTIVE = 'Solo se pueden reprogramar citas aceptadas o solicitadas.';
}
