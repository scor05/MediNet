import 'package:frontend/features/admin/domain/entities/specialty.dart';

class DoctorSpecialty {
  final int doctorId;
  final int specialtyId;
  final Specialty? specialty;

  const DoctorSpecialty({
    required this.doctorId,
    required this.specialtyId,
    this.specialty,
  });

  factory DoctorSpecialty.fromJson(Map<String, dynamic> json) {
    final specialtyJson = json['specialty'];

    return DoctorSpecialty(
      doctorId: json['id_doctor'] as int,
      specialtyId: json['id_specialty'] as int,
      specialty: specialtyJson is Map<String, dynamic>
          ? Specialty.fromJson(specialtyJson)
          : null,
    );
  }

  String get name => specialty?.name ?? 'Especialidad';
}
