import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/clinic/data/models/clinic_model.dart';

void main() {
  Map<String, dynamic> clinicJson() => {
    'id': 8,
    'name': 'San Pedro',
    'address': 'Zona 8',
    'phone': '12121212',
    'email': 'clinica@example.com',
    'created_at': '2026-08-18T20:12:48.000000Z',
    'updated_at': '2026-08-18T20:12:48.000000Z',
  };

  test('uses the active default when a create response omits is_active', () {
    final clinic = ClinicModel.fromJson(clinicJson());

    expect(clinic.isActive, isTrue);
  });

  test('preserves an explicit inactive status', () {
    final json = clinicJson()..['is_active'] = false;

    final clinic = ClinicModel.fromJson(json);

    expect(clinic.isActive, isFalse);
  });
}
