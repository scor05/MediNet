import 'package:flutter/material.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

abstract class ScheduleRepository {
  // Obtiene los horarios del doctor logueado
  Future<List<Schedule>> getDoctorSchedules();

  // Obtiene los horarios de un doctor por ID
  Future<List<Schedule>> getSchedulesByDoctorId(int doctorId);

  // Obtiene horarios de los doctores de la organización de la secretaria.
  Future<List<Schedule>> getSecretarySchedules();

  // Crea un horario
  Future<Schedule> createSchedule({
    int? doctorId,
    required int clinicId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  });

  Future<List<Schedule>> createSchedules({
    int? doctorId,
    required int clinicId,
    required List<int> daysOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) async {
    final schedules = <Schedule>[];
    for (final dayOfWeek in daysOfWeek) {
      schedules.add(
        await createSchedule(
          doctorId: doctorId,
          clinicId: clinicId,
          dayOfWeek: dayOfWeek,
          startTime: startTime,
          endTime: endTime,
          duration: duration,
        ),
      );
    }
    return schedules;
  }

  Future<Schedule> updateSchedule({
    required int id,
    required int clinicId,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  });

  Future<void> deleteSchedule(int id);
}
