import 'package:frontend/features/waitlist/domain/entities/waitlist.dart';
import 'package:frontend/features/waitlist/domain/repositories/waitlist_repository.dart';

class CreateWaitlistUsecase {
  final WaitlistRepository repository;

  CreateWaitlistUsecase(this.repository);

  Future<Waitlist> call({
    required int scheduleId,
    required DateTime date,
    required String startTime,
  }) {
    return repository.createWaitlist(
      scheduleId: scheduleId,
      date: date,
      startTime: startTime,
    );
  }
}
