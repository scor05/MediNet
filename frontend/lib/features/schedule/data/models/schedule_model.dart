import 'package:frontend/features/schedule/domain/entities/schedule.dart';

class ScheduleModel extends Schedule {
  const ScheduleModel({
    required super.id,
    required super.dayOfWeek,
    required super.startTime,
    required super.endTime,
    required super.duration,
    required super.clinicName,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'],
      dayOfWeek: json['day_of_week'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      duration: json['duration'],
      clinicName: json['clinic_name'] ?? '',
    );
  }
}
