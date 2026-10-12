import 'package:flutter/material.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/schedule/domain/repositories/schedule_repository.dart';

class CreateScheduleUsecase {
  final ScheduleRepository repository;

  CreateScheduleUsecase(this.repository);

  // Crea un horario
  Future<Schedule> call({
    int? doctorId,
    required int clinicId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) async {
    return await repository.createSchedule(
      doctorId: doctorId,
      clinicId: clinicId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
    );
  }

  Future<List<Schedule>> callMany({
    int? doctorId,
    required int clinicId,
    required List<int> daysOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) {
    return repository.createSchedules(
      doctorId: doctorId,
      clinicId: clinicId,
      daysOfWeek: daysOfWeek,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
    );
  }
}
