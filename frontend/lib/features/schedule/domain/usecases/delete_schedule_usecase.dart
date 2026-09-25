import 'package:frontend/features/schedule/domain/repositories/schedule_repository.dart';

class DeleteScheduleUsecase {
  final ScheduleRepository repository;

  DeleteScheduleUsecase(this.repository);

  Future<void> call(int id) => repository.deleteSchedule(id);
}
