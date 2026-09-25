import 'package:flutter/material.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/schedule/domain/repositories/schedule_repository.dart';

class UpdateScheduleUsecase {
  final ScheduleRepository repository;

  UpdateScheduleUsecase(this.repository);

  Future<Schedule> call({
    required int id,
    required int clinicId,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) => repository.updateSchedule(
    id: id,
    clinicId: clinicId,
    startTime: startTime,
    endTime: endTime,
    duration: duration,
  );
}
