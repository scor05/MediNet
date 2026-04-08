import '../../domain/entities/appointment.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_remote_datasource.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarRemoteDatasource datasource;

  CalendarRepositoryImpl(this.datasource);

  @override
  Future<List<Appointment>> getDoctorCalendar({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      return await datasource.getDoctorCalendar(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
    } on Exception catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    } catch (e) {
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }
}
