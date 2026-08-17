import 'package:frontend/features/waitlist/domain/entities/waitlist.dart';

class WaitlistModel extends Waitlist {
  const WaitlistModel({
    required super.id,
    required super.patientId,
    required super.targetAppointmentId,
    required super.fallbackAppointmentId,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.doctorName,
    super.clinicName,
    super.targetDate,
    super.targetStartTime,
  });

  factory WaitlistModel.fromJson(Map<String, dynamic> json) {
    return WaitlistModel(
      id: json['id'] as int,
      patientId: json['id_patient'] as int,
      targetAppointmentId: json['id_target_appointment'] as int,
      fallbackAppointmentId: json['id_fallback_appointment'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      doctorName: json['doctor_name'] as String?,
      clinicName: json['clinic_name'] as String?,
      targetDate: json['target_date'] as String?,
      targetStartTime: json['target_start_time'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_patient': patientId,
      'id_target_appointment': targetAppointmentId,
      'id_fallback_appointment': fallbackAppointmentId,
      'status': status,
    };
  }
}
