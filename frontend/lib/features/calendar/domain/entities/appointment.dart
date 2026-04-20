class Appointment {
  final int id;
  final int idSchedule;
  final DateTime date;
  final String startTime;
  final String status;
  final String patientName;
  final String clinicName;
  final int? doctorId;
  final String? doctorName;

  Appointment({
    required this.id,
    required this.idSchedule,
    required this.date,
    required this.startTime,
    required this.status,
    required this.patientName,
    required this.clinicName,
    this.doctorId,
    this.doctorName,
  });
}
