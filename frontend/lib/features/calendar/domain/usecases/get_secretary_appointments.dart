import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class GetSecretaryAppointments {
  final AppointmentRepository repository;

  GetSecretaryAppointments(this.repository);

  Future<List<Appointment>> call({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? doctorId,
    int? clinicId,
  }) async {
    return await repository.getSecretaryAppointments(
      dateFrom: dateFrom,
      dateTo: dateTo,
      doctorId: doctorId,
      clinicId: clinicId,
    );
  }
}
