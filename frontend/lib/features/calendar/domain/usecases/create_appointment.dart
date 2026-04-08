import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class CreateAppointment {
  final AppointmentRepository repository;

  CreateAppointment(this.repository);

  Future<Appointment> call({
    required int idSchedule,
    required String date,
    required String startTime,
    required String patientName,
    required String status,
  }) async {
    return await repository.createAppointment(
      idSchedule: idSchedule,
      date: date,
      startTime: startTime,
      patientName: patientName,
      status: status,
    );
  }
}
