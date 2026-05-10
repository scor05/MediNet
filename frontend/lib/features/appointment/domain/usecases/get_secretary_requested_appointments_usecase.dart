import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/repositories/appointment_repository.dart';

class GetSecretaryRequestedAppointmentsUsecase {
  final AppointmentRepository repository;

  GetSecretaryRequestedAppointmentsUsecase(this.repository);

  // Obtiene las citas solicitadas para una secretaria
  Future<List<Appointment>> call() async {
    return await repository.getSecretaryAppointments(status: 'requested');
  }
}
