import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

class GetDoctorSchedules {
  final ScheduleRepository repository;

  GetDoctorSchedules(this.repository);

  Future<List<Schedule>> call() async {
    return await repository.getDoctorSchedules();
  }
}
