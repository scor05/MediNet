import 'package:frontend/features/schedule_blockade/domain/entities/schedule_blockade.dart';

class ScheduleBlockadeModel extends ScheduleBlockade {
  const ScheduleBlockadeModel({
    required super.id,
    required super.idSchedule,
    required super.date,
    required super.startTime,
    required super.endTime,
  });

  factory ScheduleBlockadeModel.fromJson(Map<String, dynamic> json) {
    return ScheduleBlockadeModel(
      id: json['id'] as int,
      idSchedule: json['id_schedule'] as int,
      date: json['date'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }
}
