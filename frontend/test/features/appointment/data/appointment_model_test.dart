import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/appointment/data/models/appointment_model.dart';

void main() {
  // JSON base para una cita de tipo blockade con todos los campos requeridos.
  Map<String, dynamic> buildBlockadeJson({
    required String startTime,
    required String endTime,
    int id = 1,
    int scheduleId = 10,
    String date = '2025-08-01',
  }) {
    return {
      'type': 'blockade',
      'id': id,
      'schedule_id': scheduleId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'doctor': {'id': 7, 'name': 'Dr. García'},
      'clinic': {'id': 3, 'name': 'Clínica Central'},
    };
  }

  group('AppointmentModel.fromJson — rama blockade (_calcDuration)', () {
    test('calcula 60 minutos para "08:00" → "09:00"', () {
      // Arrange
      final json = buildBlockadeJson(startTime: '08:00', endTime: '09:00');

      // Act
      final model = AppointmentModel.fromJson(json);

      // Assert
      expect(model.appointmentDuration, equals(60));
    });

    test('calcula 90 minutos para "09:30" → "11:00"', () {
      // Arrange
      final json = buildBlockadeJson(startTime: '09:30', endTime: '11:00');

      // Act
      final model = AppointmentModel.fromJson(json);

      // Assert
      expect(model.appointmentDuration, equals(90));
    });

    test('calcula 15 minutos para "10:00" → "10:15"', () {
      // Arrange
      final json = buildBlockadeJson(startTime: '10:00', endTime: '10:15');

      // Act
      final model = AppointmentModel.fromJson(json);

      // Assert
      expect(model.appointmentDuration, equals(15));
    });

    test('calcula 0 minutos cuando start y end son iguales', () {
      // Arrange
      final json = buildBlockadeJson(startTime: '10:00', endTime: '10:00');

      // Act
      final model = AppointmentModel.fromJson(json);

      // Assert
      expect(model.appointmentDuration, equals(0));
    });

    test('asigna type y status como "blockade"', () {
      // Arrange
      final json = buildBlockadeJson(startTime: '08:00', endTime: '09:00');

      // Act
      final model = AppointmentModel.fromJson(json);

      // Assert
      expect(model.type, equals('blockade'));
      expect(model.status, equals('blockade'));
    });

    test('patientId es null y patientName es cadena vacía', () {
      // Arrange
      final json = buildBlockadeJson(startTime: '14:00', endTime: '15:30');

      // Act
      final model = AppointmentModel.fromJson(json);

      // Assert
      expect(model.patientId, isNull);
      expect(model.patientName, equals(''));
    });

    test(
      'asigna correctamente doctorId, doctorName, clinicId y clinicName',
      () {
        // Arrange
        final json = buildBlockadeJson(startTime: '07:00', endTime: '08:00');

        // Act
        final model = AppointmentModel.fromJson(json);

        // Assert
        expect(model.doctorId, equals(7));
        expect(model.doctorName, equals('Dr. García'));
        expect(model.clinicId, equals(3));
        expect(model.clinicName, equals('Clínica Central'));
      },
    );
  });

  group('AppointmentModel.fromJson — rama normal (cita estándar)', () {
    test('parsea correctamente una cita normal sin type blockade', () {
      // Arrange
      final json = {
        'id': 99,
        'schedule_id': 20,
        'patient': {'id': 5, 'name': 'Juan Pérez'},
        'date': '2025-09-15',
        'start_time': '10:00',
        'status': 'accepted',
        'created_at': '2025-09-01T08:00:00.000Z',
        'created_by': 1,
        'updated_at': '2025-09-01T08:00:00.000Z',
        'updated_by': 1,
        'doctor': {'id': 2, 'name': 'Dra. López'},
        'clinic': {'id': 1, 'name': 'Clínica Norte'},
        'duration': 30,
      };

      // Act
      final model = AppointmentModel.fromJson(json);

      // Assert
      expect(model.id, equals(99));
      expect(model.patientId, equals(5));
      expect(model.patientName, equals('Juan Pérez'));
      expect(model.status, equals('accepted'));
      expect(model.appointmentDuration, equals(30));
      expect(model.type, isNull); // No es blockade
    });

    test('patientId es null cuando el JSON no trae patient', () {
      // Arrange
      final json = {
        'id': 100,
        'schedule_id': 21,
        'patient': null,
        'date': '2025-09-16',
        'start_time': '11:00',
        'status': 'pending',
        'created_at': '2025-09-02T08:00:00.000Z',
        'created_by': 2,
        'updated_at': '2025-09-02T08:00:00.000Z',
        'updated_by': 2,
        'doctor': {'id': 3, 'name': 'Dr. Ramírez'},
        'clinic': {'id': 2, 'name': 'Clínica Sur'},
        'duration': 45,
      };

      // Act
      final model = AppointmentModel.fromJson(json);

      // Assert
      expect(model.patientId, isNull);
      expect(model.patientName, equals(''));
    });
  });

  test('fromCreation conserva el id del paciente vinculado', () {
    final model = AppointmentModel.fromCreation({
      'id': 101,
      'id_schedule': 21,
      'id_patient': 14,
      'name_patient': 'Ana Lopez',
      'date': '2026-08-20',
      'start_time': '09:00:00',
      'status': 'accepted',
      'created_at': '2026-08-17T08:00:00.000Z',
      'created_by': 3,
      'updated_at': '2026-08-17T08:00:00.000Z',
      'updated_by': 3,
    });

    expect(model.patientId, 14);
    expect(model.patientName, 'Ana Lopez');
  });
}
