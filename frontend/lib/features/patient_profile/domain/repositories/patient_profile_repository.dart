import 'package:frontend/features/patient_profile/domain/entities/patient_profile.dart';

abstract class PatientProfileRepository {
  Future<PatientProfile> getPatientProfile();

  Future<PatientProfile> updatePatientProfile({
    String? name,
    String? phone,
  });
}
