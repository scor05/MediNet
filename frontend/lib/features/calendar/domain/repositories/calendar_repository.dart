import '../entities/appointment.dart';

abstract class CalendarRepository {
  Future<List<Appointment>> getDoctorCalendar({
    DateTime? dateFrom,
    DateTime? dateTo,
  });
}
