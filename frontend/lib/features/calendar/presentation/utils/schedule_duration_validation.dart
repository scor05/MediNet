import 'package:flutter/material.dart';

const scheduleDurationHelpText =
    'Divide el horario en espacios individuales. '
    'Ejemplo: de 08:00 a 10:00 con 30 min crea 4 citas.';

String? validateScheduleDuration({
  required String? value,
  required TimeOfDay startTime,
  required TimeOfDay endTime,
}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Ingresa la duración';

  final duration = int.tryParse(text);
  if (duration == null) return 'Ingresa un número válido';
  if (duration < 10) return 'Mínimo 10 minutos';

  final startMinutes = startTime.hour * 60 + startTime.minute;
  final endMinutes = endTime.hour * 60 + endTime.minute;
  final rangeMinutes = endMinutes - startMinutes;
  if (rangeMinutes <= 0) return null;

  if (duration > rangeMinutes) {
    return 'No puede superar el rango de $rangeMinutes minutos';
  }
  if (rangeMinutes % duration != 0) {
    return 'Debe dividir exactamente el rango de $rangeMinutes minutos';
  }

  return null;
}
