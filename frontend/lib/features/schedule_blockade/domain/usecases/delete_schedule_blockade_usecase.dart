import 'package:frontend/features/schedule_blockade/domain/repositories/schedule_blockade_repository.dart';

class DeleteScheduleBlockadeUsecase {
  final ScheduleBlockadeRepository repository;

  DeleteScheduleBlockadeUsecase(this.repository);

  Future<void> call(int id) => repository.deleteBlockade(id);
}
