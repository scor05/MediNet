import 'admin_of.dart';

class UserProfile {
  final int id;
  final String name;
  final String email;
  final String phone;
  final bool isActive;
  final bool isDoctor;
  final bool isSecretary;
  final bool isSuperadmin;
  final List<AdminOf> adminOf;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isActive,
    required this.isDoctor,
    required this.isSecretary,
    required this.isSuperadmin,
    required this.adminOf,
  });

  // Devuelve los roles disponibles del usuario
  List<String> get roles {
    final result = <String>['patient'];

    if (isDoctor) result.add('doctor');
    if (isSecretary) result.add('secretary');
    if (adminOf.isNotEmpty) result.add('admin');

    return result;
  }
}
