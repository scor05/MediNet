import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';

class DoctorSearchResultModel extends DoctorSearchResult {
  const DoctorSearchResultModel({
    required super.id,
    required super.name,
    required super.specialty,
  });

  factory DoctorSearchResultModel.fromJson(Map<String, dynamic> json) {
    return DoctorSearchResultModel(
      id: json['id'] as int,
      name: json['name'] as String,
      specialty: json['specialty'] as String? ?? '',
    );
  }
}
