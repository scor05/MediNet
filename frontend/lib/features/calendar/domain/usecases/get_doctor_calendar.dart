import '../entities/appointment.dart';
import '../repositories/calendar_repository.dart';

class GetDoctorCalendar {
  final CalendarRepository repository;

  GetDoctorCalendar(this.repository);

  Future<List<Appointment>> call({DateTime? dateFrom, DateTime? dateTo}) {
    return repository.getDoctorCalendar(dateFrom: dateFrom, dateTo: dateTo);
  }
}
