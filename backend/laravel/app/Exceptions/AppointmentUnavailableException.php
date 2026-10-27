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

    public const INVALID_DATE = 'La fecha u hora de la cita no es válida.';

    public const PAST_BOOKING = 'No se puede agendar una cita en una fecha u hora pasada.';

    public const INACTIVE_SCHEDULE = 'El horario seleccionado no está activo.';

    public const INACTIVE_CLINIC = 'La clínica del horario seleccionado no está activa.';

    public const INACTIVE_DOCTOR = 'El médico del horario seleccionado no está activo.';

    public const WRONG_DAY = 'El horario seleccionado no atiende el día de la fecha elegida.';

    public const OUTSIDE_RANGE = 'La hora seleccionada está fuera del rango del horario.';

    public const MISALIGNED = 'La hora seleccionada no coincide con el inicio de un turno del horario.';
}
