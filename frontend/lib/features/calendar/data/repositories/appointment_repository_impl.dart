import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_datasource.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDatasource datasource;

  AppointmentRepositoryImpl(this.datasource);

  @override
  Future<List<Appointment>> getDoctorAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      return await datasource.getDoctorAppointments(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
    } on Exception catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    } catch (e) {
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }

  @override
  Future<Appointment> createAppointment({
    required int idSchedule,
    required String date,
    required String startTime,
    required String patientName,
    required String status,
  }) async {
    try {
      return await datasource.createAppointment(
        idSchedule: idSchedule,
        date: date,
        startTime: startTime,
        patientName: patientName,
        status: status,
      );
    } on Exception catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    } catch (e) {
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }
}
