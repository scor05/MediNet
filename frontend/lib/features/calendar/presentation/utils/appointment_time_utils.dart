import 'package:frontend/features/schedule/domain/entities/schedule.dart';

const daysFull = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

DateTime nextDayOfWeek({required DateTime weekStart, required int dayOfWeek}) {
  for (int i = 0; i < 7; i++) {
    final date = weekStart.add(Duration(days: i));

    if ((date.weekday - 1) == dayOfWeek) {
      return date;
    }
  }

  return weekStart;
}

List<String> buildTimeSlots(Schedule schedule) {
  final slots = <String>[];

  final startParts = schedule.startTime.split(':');
  int hour = int.parse(startParts[0]);
  int minute = int.parse(startParts[1]);

  final endParts = schedule.endTime.split(':');
  final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

  while (hour * 60 + minute < endMinutes) {
    slots.add(
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
    );

    minute += schedule.duration;

    if (minute >= 60) {
      hour += minute ~/ 60;
      minute = minute % 60;
    }
  }

  return slots;
}
