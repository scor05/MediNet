import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/waitlist/domain/entities/waitlist.dart';
import 'package:frontend/features/waitlist/presentation/pages/patient_waitlist_screen.dart';
import 'package:frontend/features/waitlist/presentation/providers/waitlist_provider.dart';
import 'package:frontend/theme/app_theme.dart';

class _FakePatientWaitlistNotifier extends PatientWaitlistNotifier {
  final List<Waitlist> waitlists;

  _FakePatientWaitlistNotifier(this.waitlists);

  @override
  FutureOr<List<Waitlist>> build() => waitlists;
}

void main() {
  testWidgets('shows doctor and appointment metadata on a waitlist card', (
    tester,
  ) async {
    final waitlist = Waitlist(
      id: 1,
      patientId: 7,
      targetAppointmentId: 12,
      fallbackAppointmentId: null,
      status: 'waiting',
      createdAt: DateTime(2026, 8, 17, 14, 5),
      updatedAt: DateTime(2026, 8, 17, 14, 5),
      doctorName: 'Ana López',
      clinicName: 'Zona 15',
      targetDate: '2026-08-20',
      targetStartTime: '09:30:00',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          patientWaitlistNotifierProvider.overrideWith(
            () => _FakePatientWaitlistNotifier([waitlist]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.theme,
          home: const PatientWaitlistScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final doctor = tester.widget<Text>(find.text('Dr. Ana López'));
    final date = tester.widget<Text>(find.text('Fecha: 20/08/2026'));
    final time = tester.widget<Text>(find.text('Hora: 09:30'));
    final registered = tester.widget<Text>(
      find.text('Registrado: 17/8/2026 14:05'),
    );

    expect(doctor.style?.fontSize, 20);
    expect(doctor.style?.fontWeight, FontWeight.w700);
    expect(find.text('En espera'), findsOneWidget);
    expect(date.style, registered.style);
    expect(time.style, registered.style);
  });
}
