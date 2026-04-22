import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/repositories/appointment_repository.dart';

class GetPatientAppointmentsUsecase {
  final AppointmentRepository repository;

  GetPatientAppointmentsUsecase(this.repository);

  Future<List<Appointment>> call({DateTime? dateFrom, DateTime? dateTo}) async {
    return await repository.getPatientAppointments(
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }
}
