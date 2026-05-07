import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/repositories/appointment_repository.dart';

class GetPublicAppointmentsUsecase {
  final AppointmentRepository repository;

  GetPublicAppointmentsUsecase(this.repository);

  Future<List<Appointment>> call({
    int? doctorId,
    int? clinicId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return repository.getPublicAppointments(
      doctorId: doctorId,
      clinicId: clinicId,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }
}
