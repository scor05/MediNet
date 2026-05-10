import 'package:frontend/features/appointment/domain/repositories/appointment_repository.dart';

class UpdateAppointmentStatusUsecase {
  final AppointmentRepository repository;

  UpdateAppointmentStatusUsecase(this.repository);

  Future<void> call({required int appointmentId, required String status}) {
    return repository.updateAppointmentStatus(
      appointmentId: appointmentId,
      status: status,
    );
  }
}
