class Specialty {
  final int id;
  final String name;

  const Specialty({required this.id, required this.name});

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      id: json['id'] as int,
      name: json['specialty']?.toString() ?? '',
    );
  }
}
