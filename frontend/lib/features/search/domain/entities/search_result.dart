import 'package:frontend/features/clinic/domain/entities/clinic_search_result.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';

class SearchResult {
  final List<DoctorSearchResult> doctors;
  final List<ClinicSearchResult> clinics;

  const SearchResult({required this.doctors, required this.clinics});
}
