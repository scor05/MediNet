import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/patient_profile/data/models/patient_profile_model.dart';

void main() {
  // JSON base válido que representa el perfil devuelto por GET /patient/profile.
  Map<String, dynamic> buildJson({
    int id = 1,
    String name = 'Laura Martínez',
    String email = 'laura@medinet.com',
    String? phone = '55551234',
    bool isActive = true,
  }) {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'is_active': isActive,
    };
  }

  group('PatientProfileModel.fromJson', () {
    test('mapea correctamente todos los campos de un JSON válido y completo', () {
      // Arrange
      final json = buildJson(
        id: 7,
        name: 'Carlos Ruiz',
        email: 'carlos@medinet.com',
        phone: '99998888',
        isActive: true,
      );

      // Act
      final model = PatientProfileModel.fromJson(json);

      // Assert
      expect(model.id, equals(7));
      expect(model.name, equals('Carlos Ruiz'));
      expect(model.email, equals('carlos@medinet.com'));
      expect(model.phone, equals('99998888'));
      expect(model.isActive, isTrue);
    });

    test('is_active en false se mapea correctamente a isActive = false', () {
      // Arrange
      final json = buildJson(isActive: false);

      // Act
      final model = PatientProfileModel.fromJson(json);

      // Assert
      expect(model.isActive, isFalse);
    });

    test('phone null en el JSON produce phone vacío en el modelo', () {
      // Arrange — La API puede enviar phone como null
      final json = buildJson(phone: null);

      // Act
      final model = PatientProfileModel.fromJson(json);

      // Assert
      expect(model.phone, equals(''));
    });

    test('fromJson retorna una instancia de PatientProfileModel', () {
      // Arrange
      final json = buildJson();

      // Act
      final model = PatientProfileModel.fromJson(json);

      // Assert — debe ser el modelo concreto, no solo la entidad base
      expect(model, isA<PatientProfileModel>());
    });

    test('es_active con valor true (no bool) se mapea como false — comparación estricta', () {
      // Arrange — is_active llega como 1 (int) en vez de true (bool)
      final json = buildJson()..['is_active'] = 1;

      // Act
      final model = PatientProfileModel.fromJson(json);

      // Assert — el modelo usa == true (estricto), así que 1 != true → isActive = false
      expect(model.isActive, isFalse);
    });
  });

  group('PatientProfileModel.toJson', () {
    test('serializa todos los campos correctamente', () {
      // Arrange
      const model = PatientProfileModel(
        id: 3,
        name: 'Ana López',
        email: 'ana@medinet.com',
        phone: '77776666',
        isActive: true,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], equals(3));
      expect(json['name'], equals('Ana López'));
      expect(json['email'], equals('ana@medinet.com'));
      expect(json['phone'], equals('77776666'));
      expect(json['is_active'], isTrue);
    });
  });
}
