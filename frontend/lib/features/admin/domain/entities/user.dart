class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final bool isAccountActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String role;
  final bool isAdmin;
  final bool isActiveInClient;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isAccountActive,
    required this.createdAt,
    required this.updatedAt,
    required this.role,
    required this.isAdmin,
    required this.isActiveInClient,
  });

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    bool? isAccountActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? role,
    bool? isAdmin,
    bool? isActiveInClient,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isAccountActive: isAccountActive ?? this.isAccountActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
      isAdmin: isAdmin ?? this.isAdmin,
      isActiveInClient: isActiveInClient ?? this.isActiveInClient,
    );
  }
}
