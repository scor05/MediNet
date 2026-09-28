import 'package:frontend/features/waitlist/domain/entities/waitlist.dart';

abstract class WaitlistRepository {
  /// Obtener los registros de lista de espera del paciente autenticado
  Future<List<Waitlist>> getPatientWaitlists();

  /// Crear un nuevo registro de lista de espera
  Future<Waitlist> createWaitlist({
    required int scheduleId,
    required DateTime date,
    required String startTime,
  });

  Future<void> createBackupAppointment({
    required int waitlistId,
    required int scheduleId,
    required DateTime date,
    required String startTime,
  });

  Future<void> declineBackupAppointment({required int waitlistId});

  /// Cancelar un registro de lista de espera
  Future<void> cancelWaitlist({required int waitlistId});
}
