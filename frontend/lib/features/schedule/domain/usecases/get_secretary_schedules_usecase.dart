import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/schedule/domain/repositories/schedule_repository.dart';

class GetSecretarySchedulesUsecase {
  final ScheduleRepository repository;

  const GetSecretarySchedulesUsecase(this.repository);

  Future<List<Schedule>> call() => repository.getSecretarySchedules();
}
