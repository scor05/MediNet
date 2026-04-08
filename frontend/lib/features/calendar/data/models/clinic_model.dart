import '../../domain/entities/clinic.dart';

class ClinicModel extends Clinic {
  const ClinicModel({
    required super.id,
    required super.name,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
