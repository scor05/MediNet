import 'package:frontend/core/utils/time_format.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

int _minutes(String time) {
  final parts = time.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

/// Horarios existentes del doctor que se cruzan con el rango propuesto en
/// alguno de los días indicados. Replica la regla del backend: el doctor no
/// puede tener dos horarios que se solapen el mismo día, sin importar la
/// clínica. Dos rangos que solo se tocan (12:00 fin / 12:00 inicio) no chocan.
List<Schedule> findScheduleConflicts({
  required List<Schedule> existing,
  required Iterable<int> days,
  required int startMinutes,
  required int endMinutes,
}) {
  if (endMinutes <= startMinutes) return const [];
  final selectedDays = days.toSet();
  final conflicts = existing.where((schedule) {
    if (!selectedDays.contains(schedule.dayOfWeek)) return false;
    return _minutes(schedule.startTime) < endMinutes &&
        _minutes(schedule.endTime) > startMinutes;
  }).toList()
    ..sort((a, b) {
      final byDay = a.dayOfWeek.compareTo(b.dayOfWeek);
      return byDay != 0
          ? byDay
          : _minutes(a.startTime).compareTo(_minutes(b.startTime));
    });
  return conflicts;
}

String describeScheduleRange(Schedule schedule) =>
    '${formatTime24(schedule.startTime)}–${formatTime24(schedule.endTime)}';
