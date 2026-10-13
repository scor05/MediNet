import 'package:flutter/material.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

List<Schedule> uniqueClinicSchedules(Iterable<Schedule> schedules) {
  final schedulesByClinic = <int, Schedule>{};
  for (final schedule in schedules) {
    schedulesByClinic.putIfAbsent(schedule.clinicId, () => schedule);
  }
  return schedulesByClinic.values.toList();
}

Schedule? scheduleContainingBlockade({
  required Iterable<Schedule> schedules,
  required int clinicId,
  required TimeOfDay startTime,
  required TimeOfDay endTime,
}) {
  final blockadeStart = startTime.hour * 60 + startTime.minute;
  final blockadeEnd = endTime.hour * 60 + endTime.minute;

  for (final schedule in schedules) {
    if (schedule.clinicId != clinicId) continue;
    final scheduleStart = _minutes(schedule.startTime);
    final scheduleEnd = _minutes(schedule.endTime);
    if (blockadeStart >= scheduleStart && blockadeEnd <= scheduleEnd) {
      return schedule;
    }
  }
  return null;
}

int _minutes(String value) {
  final parts = value.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}
