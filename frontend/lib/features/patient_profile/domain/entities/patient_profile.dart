class PatientProfile {
  final int id;
  final String name;
  final String email;
  final String phone;
  final bool isActive;

  const PatientProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isActive,
  });
}
