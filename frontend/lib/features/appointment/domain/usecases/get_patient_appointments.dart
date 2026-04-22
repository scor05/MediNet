import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class GetPatientAppointments {
  final AppointmentRepository repository;

  GetPatientAppointments(this.repository);

  Future<List<Appointment>> call({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    return await repository.getPatientAppointments(
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }
}
