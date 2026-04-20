import '../entities/appointment.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getDoctorAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
  });
  
  Future<Appointment> createAppointment({
    required int idSchedule,
    required String date,
    required String startTime,
    required String patientName,
    required String status,
  });

  Future<List<Appointment>> getSecretaryAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? doctorId,
    int? clinicId,
  });
}
