import 'package:flutter/material.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

abstract class ScheduleRepository {
  // Obtiene los horarios de un doctor
  Future<List<Schedule>> getDoctorSchedules();

  // Crea un horario
  Future<Schedule> createSchedule({
    required int clinicId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  });
}
