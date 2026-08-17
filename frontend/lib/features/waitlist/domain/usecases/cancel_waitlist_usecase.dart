import 'package:frontend/features/waitlist/domain/repositories/waitlist_repository.dart';

class CancelWaitlistUsecase {
  final WaitlistRepository repository;

  CancelWaitlistUsecase(this.repository);

  Future<void> call({required int waitlistId}) {
    return repository.cancelWaitlist(waitlistId: waitlistId);
  }
}
