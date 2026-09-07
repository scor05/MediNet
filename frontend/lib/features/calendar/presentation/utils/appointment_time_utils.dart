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

DateTime nextScheduleDate({
  required DateTime weekStart,
  required DateTime today,
  required int dayOfWeek,
}) {
  final normalizedToday = DateTime(today.year, today.month, today.day);
  final normalizedWeekStart = DateTime(
    weekStart.year,
    weekStart.month,
    weekStart.day,
  );
  final startingDate = normalizedWeekStart.isBefore(normalizedToday)
      ? normalizedToday
      : normalizedWeekStart;
  final targetWeekday = dayOfWeek + 1;
  final daysUntilTarget = (targetWeekday - startingDate.weekday) % 7;

  return startingDate.add(Duration(days: daysUntilTarget));
}

bool isSelectableScheduleDate({
  required DateTime date,
  required DateTime today,
  required int dayOfWeek,
}) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final normalizedToday = DateTime(today.year, today.month, today.day);

  return !normalizedDate.isBefore(normalizedToday) &&
      normalizedDate.weekday - 1 == dayOfWeek;
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
