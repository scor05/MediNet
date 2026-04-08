import '../repositories/schedule_repository.dart';

class CreateSchedule {
  final ScheduleRepository repository;

  CreateSchedule(this.repository);

  Future<void> call({
    required int idClinic,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required int duration,
  }) async {
    return await repository.createSchedule(
      idClinic: idClinic,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
    );
  }
}
