import 'package:frontend/features/user/domain/entities/patient_profile.dart';
import 'package:frontend/features/user/domain/entities/user.dart';

abstract class UserRepository {
  // Devuelve todos los usuarios que no son superadmin
  Future<List<User>> getAvailableUsers(String search);

  // Busca cuentas activas que pueden vincularse como pacientes.
  Future<List<User>> searchPatients(String search);

  // Guarda el token FCM del usuario
  Future<void> saveFcmToken();

  // Obtiene el perfil básico del paciente autenticado
  Future<PatientProfile> getPatientProfile();
}
