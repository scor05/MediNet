import '../../domain/entities/admin_of.dart';

class AdminOfModel extends AdminOf {
  const AdminOfModel({required super.clientId, required super.clientName});

  factory AdminOfModel.fromJson(Map<String, dynamic> json) {
    return AdminOfModel(
      clientId: json['client_id'] as int,
      clientName: json['client_name'] as String,
    );
  }
}
