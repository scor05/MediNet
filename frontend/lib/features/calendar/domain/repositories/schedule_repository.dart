import '../entities/schedule.dart';

abstract class ScheduleRepository {
  Future<List<Schedule>> getDoctorSchedules();
  Future<void> createSchedule({
    required int idClinic,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required int duration,
  });
}
