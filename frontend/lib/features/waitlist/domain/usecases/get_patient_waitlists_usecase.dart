import 'package:frontend/features/waitlist/domain/entities/waitlist.dart';
import 'package:frontend/features/waitlist/domain/repositories/waitlist_repository.dart';

class GetPatientWaitlistsUsecase {
  final WaitlistRepository repository;

  GetPatientWaitlistsUsecase(this.repository);

  Future<List<Waitlist>> call() {
    return repository.getPatientWaitlists();
  }
}
