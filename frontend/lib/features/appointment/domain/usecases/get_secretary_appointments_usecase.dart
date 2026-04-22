import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/repositories/appointment_repository.dart';

class GetSecretaryAppointmentsUsecase {
  final AppointmentRepository repository;

  GetSecretaryAppointmentsUsecase(this.repository);

  // Obtiene las citas de un secretario
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
