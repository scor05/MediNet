import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/repositories/appointment_repository.dart';

class GetDoctorAppointmentsUsecase {
  final AppointmentRepository repository;

  GetDoctorAppointmentsUsecase(this.repository);

  // Obtiene las citas de un doctor
  Future<List<Appointment>> call({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? clientId,
    int? clinicId,
  }) {
    return repository.getDoctorAppointments(
      dateFrom: dateFrom,
      dateTo: dateTo,
      clientId: clientId,
      clinicId: clinicId,
    );
  }
}
