import 'package:frontend/features/clinic/domain/entities/clinic_search_result.dart';

class ClinicSearchResultModel extends ClinicSearchResult {
  const ClinicSearchResultModel({
    required super.id,
    required super.name,
    required super.address,
  });

  factory ClinicSearchResultModel.fromJson(Map<String, dynamic> json) {
    return ClinicSearchResultModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String? ?? '',
    );
  }
}
