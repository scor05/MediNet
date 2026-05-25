import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/schedule/domain/repositories/schedule_repository.dart';

class GetSchedulesByDoctorIdUsecase {
  final ScheduleRepository repository;

  GetSchedulesByDoctorIdUsecase(this.repository);

  Future<List<Schedule>> call(int doctorId) {
    return repository.getSchedulesByDoctorId(doctorId);
  }
}
