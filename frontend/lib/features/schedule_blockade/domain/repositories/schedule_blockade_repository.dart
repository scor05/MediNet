import 'package:flutter/material.dart';
import 'package:frontend/features/schedule_blockade/domain/entities/schedule_blockade.dart';

abstract class ScheduleBlockadeRepository {
  Future<ScheduleBlockade> createBlockade({
    required int scheduleId,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  });
}
