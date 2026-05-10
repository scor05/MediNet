import 'package:frontend/features/calendar/domain/repositories/public_calendar_repository.dart';

class CreatePublicAppointmentRequestUsecase {
  final PublicCalendarRepository repository;

  CreatePublicAppointmentRequestUsecase(this.repository);

  Future<void> call({
    required int scheduleId,
    required int patientId,
    required String patientName,
    required DateTime date,
    required String startTime,
  }) {
    return repository.createAppointmentRequest(
      scheduleId: scheduleId,
      patientId: patientId,
      patientName: patientName,
      date: date,
      startTime: startTime,
    );
  }
}
