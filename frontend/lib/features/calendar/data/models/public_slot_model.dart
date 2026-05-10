import 'package:frontend/features/calendar/domain/entities/public_slot.dart';

class PublicSlotModel extends PublicSlot {
  const PublicSlotModel({
    required super.scheduleId,
    required super.startTime,
    required super.endTime,
    required super.doctorId,
    required super.doctorName,
    required super.clinicId,
    required super.clinicName,
  });

  factory PublicSlotModel.fromJson(Map<String, dynamic> json) {
    return PublicSlotModel(
      scheduleId: json['schedule_id'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      doctorId: json['doctor']['id'] as int,
      doctorName: json['doctor']['name'] as String,
      clinicId: json['clinic']['id'] as int,
      clinicName: json['clinic']['name'] as String,
    );
  }
}
