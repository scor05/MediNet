class Client {
  final int id;
  final String name;
  final bool isActive;

  Client({required this.id, required this.name, required this.isActive});

  Client copyWith({int? id, String? name, bool? isActive}) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }
}
