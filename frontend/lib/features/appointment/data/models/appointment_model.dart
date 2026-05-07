import 'package:frontend/features/appointment/domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.scheduleId,
    super.patientId,
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

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as int,
      scheduleId: json['schedule_id'] as int,
      patientId: json['patient']?['id'] as int?,
      patientName: json['patient']?['name'] ?? '',
      date: DateTime.parse(json['date']),
      startTime: json['start_time'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'] as int,
      updatedAt: DateTime.parse(json['updated_at']),
      updatedBy: json['updated_by'] as int,
      doctorId: json['doctor']['id'] as int,
      doctorName: json['doctor']['name'] as String,
      clinicId: json['clinic']['id'] as int,
      clinicName: json['clinic']['name'] as String,
      appointmentDuration: json['duration'] as int,
    );
  }

  factory AppointmentModel.fromCreation(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      scheduleId: json['id_schedule'],
      patientId: null,
      patientName: json['name_patient'],
      date: DateTime.parse(json['date']),
      startTime: json['start_time'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
      updatedAt: DateTime.parse(json['updated_at']),
      updatedBy: json['updated_by'],
      doctorId: 0,
      doctorName: '',
      clinicId: 0,
      clinicName: '',
      appointmentDuration: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_schedule': scheduleId,
      'id_patient': patientId,
      'name_patient': patientName,
      'date': date,
      'start_time': startTime,
      'status': status,
    };
  }
}
