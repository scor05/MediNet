import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/waitlist/data/models/waitlist_model.dart';

void main() {
  test('decodes the appointment context returned by the patient endpoint', () {
    final waitlist = WaitlistModel.fromJson({
      'id': 3,
      'id_patient': 7,
      'id_target_appointment': 12,
      'id_fallback_appointment': null,
      'status': 'waiting',
      'created_at': '2026-08-18T14:05:00.000Z',
      'updated_at': '2026-08-18T14:05:00.000Z',
      'doctor_name': 'Ana López',
      'clinic_name': 'Zona 15',
      'target_date': '2026-08-20',
      'target_start_time': '09:30:00',
    });

    expect(waitlist.doctorName, 'Ana López');
    expect(waitlist.clinicName, 'Zona 15');
    expect(waitlist.targetDate, '2026-08-20');
    expect(waitlist.targetStartTime, '09:30:00');
  });
}
