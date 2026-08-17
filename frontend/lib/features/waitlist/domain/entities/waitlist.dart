class Waitlist {
  final int id;
  final int patientId;
  final int targetAppointmentId;
  final int fallbackAppointmentId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Datos contextuales opcionales (del join con appointments/schedules/clinics/doctors)
  final String? doctorName;
  final String? clinicName;
  final String? targetDate;
  final String? targetStartTime;

  const Waitlist({
    required this.id,
    required this.patientId,
    required this.targetAppointmentId,
    required this.fallbackAppointmentId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.doctorName,
    this.clinicName,
    this.targetDate,
    this.targetStartTime,
  });

  bool get isActive => status == 'active';
  bool get isNotified => status == 'notified';
  bool get isCancelled => status == 'cancelled';
}
