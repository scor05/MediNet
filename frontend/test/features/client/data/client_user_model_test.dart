import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/client/data/models/client_user_model.dart';

void main() {
  Map<String, dynamic> buildJson(int role) {
    return {
      'user': {
        'id': 7,
        'name': 'Ana López',
        'email': 'ana@medinet.com',
        'phone': '55551234',
        'is_active': true,
        'created_at': '2026-07-26T12:00:00.000Z',
        'updated_at': '2026-07-26T12:00:00.000Z',
      },
      'role': role,
      'is_admin': false,
      'is_active': true,
    };
  }

  group('ClientUserModel.fromJson role mapping', () {
    test('maps role 0 to admin', () {
      expect(ClientUserModel.fromJson(buildJson(0)).role, 'admin');
    });

    test('maps role 1 to doctor', () {
      expect(ClientUserModel.fromJson(buildJson(1)).role, 'doctor');
    });

    test('maps role 2 to secretary', () {
      expect(ClientUserModel.fromJson(buildJson(2)).role, 'secretary');
    });
  });
}
