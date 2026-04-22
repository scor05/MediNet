class Clinic {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  Clinic copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Clinic(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
