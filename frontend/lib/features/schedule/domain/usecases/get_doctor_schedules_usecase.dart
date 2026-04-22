import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/schedule/domain/repositories/schedule_repository.dart';

class GetDoctorSchedulesUsecase {
  final ScheduleRepository repository;

  GetDoctorSchedulesUsecase(this.repository);

  // Se devuelven todos los horarios del doctor logueado
  Future<List<Schedule>> call() async {
    return await repository.getDoctorSchedules();
  }
}
