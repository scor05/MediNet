import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/domain/entities/admin_of.dart';
import 'package:frontend/features/auth/domain/entities/user_profile.dart';

void main() {
  // Helper para construir un UserProfile con valores base y overrides puntuales.
  UserProfile buildProfile({
    bool isDoctor = false,
    bool isSecretary = false,
    bool isSuperadmin = false,
    List<AdminOf> adminOf = const [],
  }) {
    return UserProfile(
      id: 1,
      name: 'Test User',
      email: 'test@medinet.com',
      phone: '12345678',
      isActive: true,
      isDoctor: isDoctor,
      isSecretary: isSecretary,
      isSuperadmin: isSuperadmin,
      adminOf: adminOf,
    );
  }

  group('UserProfile.roles', () {
    test('siempre contiene "patient" aunque todos los flags sean false', () {
      // Arrange
      final profile = buildProfile();

      // Act
      final roles = profile.roles;

      // Assert
      expect(roles, contains('patient'));
      expect(roles, hasLength(1));
    });

    test('incluye "doctor" cuando isDoctor es true', () {
      // Arrange
      final profile = buildProfile(isDoctor: true);

      // Act
      final roles = profile.roles;

      // Assert
      expect(roles, containsAll(['patient', 'doctor']));
      expect(roles, hasLength(2));
    });

    test('incluye "secretary" cuando isSecretary es true', () {
      // Arrange
      final profile = buildProfile(isSecretary: true);

      // Act
      final roles = profile.roles;

      // Assert
      expect(roles, containsAll(['patient', 'secretary']));
      expect(roles, hasLength(2));
    });

    test('incluye "admin" cuando adminOf no está vacío', () {
      // Arrange
      final profile = buildProfile(
        adminOf: [const AdminOf(clientId: 10, clientName: 'Clínica Test')],
      );

      // Act
      final roles = profile.roles;

      // Assert
      expect(roles, containsAll(['patient', 'admin']));
      expect(roles, hasLength(2));
    });

    test('NO incluye "admin" cuando adminOf está vacío', () {
      // Arrange
      final profile = buildProfile(adminOf: const []);

      // Act
      final roles = profile.roles;

      // Assert
      expect(roles, isNot(contains('admin')));
    });

    // isSuperadmin es un atributo de perfil pero NO genera un rol adicional
    // en la lista. Este test lo documenta explícitamente.
    test('isSuperadmin no agrega ningún rol a la lista', () {
      // Arrange
      final profile = buildProfile(isSuperadmin: true);

      // Act
      final roles = profile.roles;

      // Assert — sigue siendo solo ['patient']
      expect(roles, hasLength(1));
      expect(roles, contains('patient'));
    });

    // isSuperadmin se incluye para simular el perfil más completo posible,
    // pero los 4 roles provienen de isDoctor, isSecretary y adminOf.
    test('incluye todos los roles cuando isDoctor, isSecretary y adminOf están activos', () {
      // Arrange
      final profile = buildProfile(
        isDoctor: true,
        isSecretary: true,
        adminOf: [const AdminOf(clientId: 5, clientName: 'Clínica Principal')],
      );

      // Act
      final roles = profile.roles;

      // Assert
      expect(roles, containsAll(['patient', 'doctor', 'secretary', 'admin']));
      expect(roles, hasLength(4));
    });
  });
}
