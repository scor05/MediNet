import 'package:frontend/features/waitlist/domain/entities/waitlist.dart';

abstract class WaitlistRepository {
  /// Obtener los registros de lista de espera del paciente autenticado
  Future<List<Waitlist>> getPatientWaitlists();

  /// Crear un nuevo registro de lista de espera
  Future<Waitlist> createWaitlist({
    required int targetAppointmentId,
    required int fallbackAppointmentId,
  });

  /// Cancelar un registro de lista de espera
  Future<void> cancelWaitlist({required int waitlistId});
}
