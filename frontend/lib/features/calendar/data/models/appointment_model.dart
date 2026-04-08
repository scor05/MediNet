import '../../domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  AppointmentModel({
    required super.id,
    required super.idSchedule,
    required super.date,
    required super.startTime,
    required super.status,
    required super.patientName,
    required super.clinicName,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      idSchedule: json['id_schedule'] ?? json['schedule_id'],
      date: DateTime.parse(json['date']),
      startTime: json['start_time'],
      status: json['status'],
      patientName: json['patient'] != null ? json['patient']['name'] : (json['name_patient'] ?? 'Desconocido'),
      clinicName: json['clinic'] != null ? json['clinic']['name'] : (json['schedule'] != null && json['schedule']['clinic'] != null ? json['schedule']['clinic']['name'] : 'Clínica no asignada'),
    );
  }
}
