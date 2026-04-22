class Client {
  final int id;
  final String name;
  final String nit;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Client({
    required this.id,
    required this.name,
    required this.nit,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Client copyWith({
    int? id,
    String? name,
    String? nit,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      nit: nit ?? this.nit,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
