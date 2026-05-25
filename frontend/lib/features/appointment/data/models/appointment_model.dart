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
    super.type,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'blockade') {
      return AppointmentModel._fromBlockade(json);
    }
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

  factory AppointmentModel._fromBlockade(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date']);
    return AppointmentModel(
      id: json['id'] as int,
      scheduleId: json['schedule_id'] as int,
      patientId: null,
      patientName: '',
      date: date,
      startTime: json['start_time'] as String,
      status: 'blockade',
      createdAt: date,
      createdBy: 0,
      updatedAt: date,
      updatedBy: 0,
      doctorId: json['doctor']['id'] as int,
      doctorName: json['doctor']['name'] as String,
      clinicId: json['clinic']['id'] as int,
      clinicName: json['clinic']['name'] as String,
      appointmentDuration: _calcDuration(
        json['start_time'] as String,
        json['end_time'] as String,
      ),
      type: 'blockade',
    );
  }

  static int _calcDuration(String startTime, String endTime) {
    final s = startTime.split(':');
    final e = endTime.split(':');
    final startMins = int.parse(s[0]) * 60 + int.parse(s[1]);
    final endMins = int.parse(e[0]) * 60 + int.parse(e[1]);
    return endMins - startMins;
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
