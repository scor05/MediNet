import 'package:frontend/features/calendar/domain/entities/public_slot.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';
import 'package:frontend/features/user/domain/entities/user.dart';

abstract class PublicCalendarRepository {
  // Obtiene los doctores disponibles para calendario público
  Future<List<User>> getDoctors({int? clinicId});

  // Obtiene las clínicas disponibles para calendario público
  Future<List<Clinic>> getClinics({int? doctorId});

  // Obtiene los slots disponibles para doctor, clínica y fecha
  Future<List<PublicSlot>> getSlots({
    required int doctorId,
    required int clinicId,
    required DateTime date,
  });
}
