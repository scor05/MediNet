import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/clinic/data/providers/clinic_data_providers.dart';
import 'package:frontend/features/clinic/domain/usecases/create_clinic_usecase.dart';
import 'package:frontend/features/clinic/domain/usecases/get_clinics_usecase.dart';

// Provider para el usecase createClinic
final createClinicUsecaseProvider = Provider((ref) {
  return CreateClinicUsecase(ref.read(clinicRepositoryProvider));
});

// Provider para el usecase getClientClinics
final getClinicsUsecaseProvider = Provider((ref) {
  return GetClinicsUsecase(ref.read(clinicRepositoryProvider));
});
