import '../../domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  AppointmentModel({
    required super.id,
    required super.date,
    required super.startTime,
    required super.status,
    required super.doctorName,
    required super.patientName,
    required super.clinicName,
    required super.clinicAddress,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      startTime: json['start_time'],
      status: json['status'],
      doctorName: json['doctor']['name'],
      patientName: json['patient']['name'],
      clinicName: json['clinic']['name'],
      clinicAddress: json['clinic']['address'],
    );
  }
}
