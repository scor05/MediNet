import 'package:flutter/material.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/schedule/domain/repositories/schedule_repository.dart';

class CreateScheduleUsecase {
  final ScheduleRepository repository;

  CreateScheduleUsecase(this.repository);

  // Crea un horario
  Future<Schedule> call({
    required int clinicId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) async {
    return await repository.createSchedule(
      clinicId: clinicId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
    );
  }
}
