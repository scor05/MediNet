import '../../domain/entities/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_datasource.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDatasource datasource;

  ScheduleRepositoryImpl(this.datasource);

  @override
  Future<List<Schedule>> getDoctorSchedules() async {
    try {
      return await datasource.getDoctorSchedules();
    } on Exception catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    } catch (e) {
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }

  @override
  Future<void> createSchedule({
    required int idClinic,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required int duration,
  }) async {
    try {
      await datasource.createSchedule(
        idClinic: idClinic,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
      );
    } on Exception catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    } catch (e) {
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }
}
