import 'package:frontend/features/appointment/domain/repositories/appointment_repository.dart';

class DecideAppointmentUsecase {
  final AppointmentRepository repository;

  DecideAppointmentUsecase(this.repository);

  Future<void> call({required int appointmentId, required String decision}) =>
      repository.decideAppointment(
        appointmentId: appointmentId,
        decision: decision,
      );
}
