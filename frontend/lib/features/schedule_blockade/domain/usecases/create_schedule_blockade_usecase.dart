import 'package:flutter/material.dart';
import 'package:frontend/features/schedule_blockade/domain/entities/schedule_blockade.dart';
import 'package:frontend/features/schedule_blockade/domain/repositories/schedule_blockade_repository.dart';

class CreateScheduleBlockadeUsecase {
  final ScheduleBlockadeRepository repository;

  CreateScheduleBlockadeUsecase(this.repository);

  Future<ScheduleBlockade> call({
    required int scheduleId,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) {
    return repository.createBlockade(
      scheduleId: scheduleId,
      date: date,
      startTime: startTime,
      endTime: endTime,
    );
  }
}
