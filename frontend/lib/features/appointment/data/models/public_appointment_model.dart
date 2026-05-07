import 'package:frontend/features/appointment/domain/entities/appointment.dart';

class PublicAppointmentModel extends Appointment {
  PublicAppointmentModel({
    required super.id,
    required super.scheduleId,
    required super.patientId,
    required super.patientName,
    required super.date,
    required super.startTime,
    required super.status,
    required super.createdAt,
    required super.createdBy,
    required super.updatedAt,
    required super.updatedBy,
    required super.doctorId,
    required super.doctorName,
    required super.clinicId,
    required super.clinicName,
    required super.appointmentDuration,
  });

  factory PublicAppointmentModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    return PublicAppointmentModel(
      id: json['id'] as int? ?? 0,
      scheduleId: json['schedule_id'] as int? ?? 0,
      patientId: null,
      patientName: 'Cita reservada',
      date: DateTime.parse(json['date'] as String),
      startTime: json['start_time'] as String,
      status: json['status'] as String? ?? 'accepted',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : now,
      createdBy: json['created_by'] as int? ?? 0,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : now,
      updatedBy: json['updated_by'] as int? ?? 0,
      doctorId: json['doctor_id'] as int,
      doctorName: json['doctor_name'] as String,
      clinicId: json['clinic_id'] as int,
      clinicName: json['clinic_name'] as String,
      appointmentDuration: json['duration'] as int,
    );
  }
}
