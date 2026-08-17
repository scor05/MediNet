import 'package:frontend/features/waitlist/domain/entities/waitlist.dart';
import 'package:frontend/features/waitlist/domain/repositories/waitlist_repository.dart';

class CreateWaitlistUsecase {
  final WaitlistRepository repository;

  CreateWaitlistUsecase(this.repository);

  Future<Waitlist> call({
    required int targetAppointmentId,
    required int fallbackAppointmentId,
  }) {
    return repository.createWaitlist(
      targetAppointmentId: targetAppointmentId,
      fallbackAppointmentId: fallbackAppointmentId,
    );
  }
}
