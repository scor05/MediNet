import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/clinic/data/datasources/clinic_remote_datasource.dart';
import 'package:frontend/features/clinic/data/repositories/clinic_repository_impl.dart';
import 'package:frontend/features/clinic/domain/repositories/clinic_repository.dart';

// Provider para el datasource de clínicas
final clinicRemoteDatasourceProvider = Provider((ref) {
  return ClinicRemoteDatasource();
});

// Provider para la implementacion del repository de clínicas
final clinicRepositoryProvider = Provider<ClinicRepository>((ref) {
  return ClinicRepositoryImpl(ref.read(clinicRemoteDatasourceProvider));
});
