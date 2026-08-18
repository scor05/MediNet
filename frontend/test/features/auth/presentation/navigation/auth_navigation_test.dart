import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/domain/entities/user_profile.dart';
import 'package:frontend/features/auth/presentation/navigation/auth_navigation.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_shell.dart';
import 'package:frontend/features/search/presentation/pages/search_screen.dart';
import 'package:frontend/features/waitlist/presentation/pages/patient_waitlist_screen.dart';

void main() {
  test('patient navigation places waitlist immediately after scheduling', () {
    const profile = UserProfile(
      id: 7,
      name: 'Paciente',
      email: 'paciente@medinet.lat',
      phone: '5555-5555',
      isActive: true,
      isDoctor: false,
      isSecretary: false,
      isSuperadmin: false,
      adminOf: [],
    );

    final shell = AuthNavigation.screenForRole('patient', profile);

    expect(shell, isA<CalendarShell>());
    final patientShell = shell as CalendarShell;
    expect(patientShell.extraPages, hasLength(2));
    expect(patientShell.extraPages[0], isA<SearchScreen>());
    expect(patientShell.extraPages[1], isA<PatientWaitlistScreen>());
    expect(patientShell.extraItems[0].label, 'Agendar Cita');
    expect(patientShell.extraItems[1].label, 'En espera');
    expect(
      (patientShell.extraItems[1].icon as Icon).icon,
      Icons.hourglass_empty,
    );
  });
}
