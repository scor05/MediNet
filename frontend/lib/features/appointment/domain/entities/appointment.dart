class Appointment {
  final int id;
  final int scheduleId;
  final int? patientId;
  final String patientName;
  final DateTime date;
  final String startTime;
  final String status;
  final DateTime createdAt;
  final int createdBy;
  final DateTime updatedAt;
  final int updatedBy;
  final int doctorId;
  final String doctorName;
  final int clinicId;
  final String clinicName;
  final int appointmentDuration;

  const Appointment({
    required this.id,
    required this.scheduleId,
    this.patientId,
    required this.patientName,
    required this.date,
    required this.startTime,
    required this.status,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.doctorId,
    required this.doctorName,
    required this.clinicId,
    required this.clinicName,
    required this.appointmentDuration,
  });

  Appointment copyWith({
    int? id,
    int? scheduleId,
    int? patientId,
    String? patientName,
    DateTime? date,
    String? startTime,
    String? status,
    DateTime? createdAt,
    int? createdBy,
    DateTime? updatedAt,
    int? updatedBy,
    int? doctorId,
    String? doctorName,
    int? clinicId,
    String? clinicName,
    int? appointmentDuration,
  }) {
    return Appointment(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      appointmentDuration: appointmentDuration ?? this.appointmentDuration,
    );
  }
}
