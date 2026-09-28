import 'package:frontend/features/waitlist/domain/repositories/waitlist_repository.dart';

class CreateBackupAppointmentUsecase {
  final WaitlistRepository repository;

  CreateBackupAppointmentUsecase(this.repository);

  Future<void> call({
    required int waitlistId,
    required int scheduleId,
    required DateTime date,
    required String startTime,
  }) => repository.createBackupAppointment(
    waitlistId: waitlistId,
    scheduleId: scheduleId,
    date: date,
    startTime: startTime,
  );
}
