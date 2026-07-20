import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/models/admin_of_model.dart';
import 'package:frontend/features/auth/data/models/user_profile_model.dart';

void main() {
  // JSON base válido que representa un perfil completo desde la API.
  Map<String, dynamic> buildJson({
    int id = 1,
    String name = 'María García',
    String email = 'maria@medinet.com',
    String phone = '55551234',
    bool isActive = true,
    bool isDoctor = false,
    bool isSecretary = false,
    bool superadmin = false,
    List<Map<String, dynamic>>? adminOf,
  }) {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'is_active': isActive,
      'is_doctor': isDoctor,
      'is_secretary': isSecretary,
      'superadmin': superadmin, // Nombre diferente al del campo en Dart (isSuperadmin)
      'admin_of': adminOf,
    };
  }

  group('UserProfileModel.fromJson', () {
    test('mapea correctamente todos los campos de un JSON válido y completo', () {
      // Arrange
      final json = buildJson(
        id: 42,
        name: 'Carlos Ruiz',
        email: 'carlos@medinet.com',
        phone: '99998888',
        isActive: true,
        isDoctor: true,
        isSecretary: false,
        superadmin: false,
        adminOf: [],
      );

      // Act
      final model = UserProfileModel.fromJson(json);

      // Assert
      expect(model.id, equals(42));
      expect(model.name, equals('Carlos Ruiz'));
      expect(model.email, equals('carlos@medinet.com'));
      expect(model.phone, equals('99998888'));
      expect(model.isActive, isTrue);
      expect(model.isDoctor, isTrue);
      expect(model.isSecretary, isFalse);
      expect(model.isSuperadmin, isFalse);
    });

    test('mapea "superadmin" del JSON al campo isSuperadmin de Dart', () {
      // Arrange — El campo en el JSON se llama "superadmin", no "isSuperadmin"
      final json = buildJson(superadmin: true);

      // Act
      final model = UserProfileModel.fromJson(json);

      // Assert
      expect(model.isSuperadmin, isTrue);
    });

    test('parsea admin_of con múltiples entradas correctamente', () {
      // Arrange
      final json = buildJson(
        adminOf: [
          {'client_id': 10, 'client_name': 'Clínica Norte'},
          {'client_id': 20, 'client_name': 'Clínica Sur'},
        ],
      );

      // Act
      final model = UserProfileModel.fromJson(json);

      // Assert
      expect(model.adminOf, hasLength(2));
      expect(model.adminOf[0], isA<AdminOfModel>());
      expect(model.adminOf[0].clientId, equals(10));
      expect(model.adminOf[0].clientName, equals('Clínica Norte'));
      expect(model.adminOf[1].clientId, equals(20));
      expect(model.adminOf[1].clientName, equals('Clínica Sur'));
    });

    test('produce adminOf vacío cuando admin_of es null en el JSON', () {
      // Arrange — La API puede omitir el campo y llegar como null
      final json = buildJson(adminOf: null);

      // Act
      final model = UserProfileModel.fromJson(json);

      // Assert
      expect(model.adminOf, isEmpty);
    });

    test('produce adminOf vacío cuando admin_of es una lista vacía', () {
      // Arrange
      final json = buildJson(adminOf: []);

      // Act
      final model = UserProfileModel.fromJson(json);

      // Assert
      expect(model.adminOf, isEmpty);
    });

    test('is_active en false se mapea correctamente a isActive = false', () {
      // Arrange
      final json = buildJson(isActive: false);

      // Act
      final model = UserProfileModel.fromJson(json);

      // Assert
      expect(model.isActive, isFalse);
    });

    // El test anterior cubre flags en false. Este test verifica
    // que fromJson retorna el tipo concreto correcto.
    test('fromJson retorna una instancia de UserProfileModel', () {
      // Arrange
      final json = buildJson();

      // Act
      final model = UserProfileModel.fromJson(json);

      // Assert — debe ser el modelo concreto, no solo la entidad base
      expect(model, isA<UserProfileModel>());
    });
  });
}
