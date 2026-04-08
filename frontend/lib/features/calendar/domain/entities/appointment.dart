class Appointment {
  final int id;
  final DateTime date;
  final String startTime;
  final String status;
  final String doctorName;
  final String patientName;
  final String clinicName;
  final String clinicAddress;

  Appointment({
    required this.id,
    required this.date,
    required this.startTime,
    required this.status,
    required this.doctorName,
    required this.patientName,
    required this.clinicName,
    required this.clinicAddress,
  });
}
