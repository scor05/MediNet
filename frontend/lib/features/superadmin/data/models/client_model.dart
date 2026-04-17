import '../../domain/entities/client.dart';

class ClientModel extends Client {
  ClientModel({
    required super.id,
    required super.name,
    required super.isActive,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as int,
      name: json['name'] as String,
      isActive: json['is_active'] as bool,
    );
  }
}
