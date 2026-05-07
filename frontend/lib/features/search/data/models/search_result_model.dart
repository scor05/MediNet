import 'package:frontend/features/clinic/data/models/clinic_search_result_model.dart';
import 'package:frontend/features/search/domain/entities/search_result.dart';
import 'package:frontend/features/user/data/models/doctor_search_result_model.dart';

class SearchResultModel extends SearchResult {
  const SearchResultModel({required super.doctors, required super.clinics});

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      doctors: (json['doctors'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                DoctorSearchResultModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      clinics: (json['clinics'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                ClinicSearchResultModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
