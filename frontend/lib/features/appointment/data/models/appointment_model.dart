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
      id: json['id'],
      scheduleId: json['id_schedule'],
      patientId: json['id_patient'],
      patientName: json['patient_name'],
      date: DateTime.parse(json['date']),
      startTime: json['start_time'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
      updatedAt: DateTime.parse(json['updated_at']),
      updatedBy: json['updated_by'],
      doctorId: json['doctor_id'],
      doctorName: json['doctor_name'],
      clinicId: json['clinic_id'],
      clinicName: json['clinic_name'],
      appointmentDuration: json['appointment_duration'],
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
