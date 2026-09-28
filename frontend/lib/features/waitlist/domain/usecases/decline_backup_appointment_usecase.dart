import 'package:frontend/features/waitlist/domain/repositories/waitlist_repository.dart';

class DeclineBackupAppointmentUsecase {
  final WaitlistRepository repository;

  DeclineBackupAppointmentUsecase(this.repository);

  Future<void> call(int waitlistId) =>
      repository.declineBackupAppointment(waitlistId: waitlistId);
}
