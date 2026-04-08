import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class GetDoctorCalendar {
  final AppointmentRepository repository;

  GetDoctorCalendar(this.repository);

  Future<List<Appointment>> call({DateTime? dateFrom, DateTime? dateTo}) {
    return repository.getDoctorAppointments(dateFrom: dateFrom, dateTo: dateTo);
  }
}
