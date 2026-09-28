import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin/presentation/pages/admin_panel.dart';
import 'package:frontend/features/auth/domain/entities/admin_of.dart';
import 'package:frontend/features/auth/domain/entities/user_profile.dart';
import 'package:frontend/features/auth/presentation/navigation/auth_navigation.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_shell.dart';
import 'package:frontend/features/calendar/presentation/pages/secretary_requested_appointments_screen.dart';
import 'package:frontend/features/search/presentation/pages/search_screen.dart';
import 'package:frontend/features/waitlist/presentation/pages/patient_waitlist_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('doctor navigation includes their requested appointments page', () {
    const profile = UserProfile(
      id: 3,
      name: 'Doctor',
      email: 'doctor@medinet.lat',
      phone: '5555-3333',
      isActive: true,
      isDoctor: true,
      isSecretary: false,
      isSuperadmin: false,
      adminOf: [],
    );

    final shell = AuthNavigation.screenForRole('doctor', profile);

    expect(shell, isA<CalendarShell>());
    final doctorShell = shell as CalendarShell;
    expect(doctorShell.extraPages, hasLength(1));
    expect(
      doctorShell.extraPages.single,
      isA<DoctorRequestedAppointmentsScreen>(),
    );
    expect(doctorShell.extraItems.single.label, 'Solicitadas');
    expect(
      (doctorShell.extraItems.single.icon as Icon).icon,
      Icons.assignment_outlined,
    );
  });

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

  test('restored session returns to its only available role', () async {
    SharedPreferences.setMockInitialValues({});

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

    final screen = await AuthNavigation.screenAfterLogin(profile);

    expect(screen, isA<CalendarShell>());
    expect(
      (await SharedPreferences.getInstance()).getString('last_role'),
      'patient',
    );
  });

  test('administrator destination retains the profile for settings', () {
    const profile = UserProfile(
      id: 9,
      name: 'Administrador',
      email: 'admin@medinet.lat',
      phone: '5555-9999',
      isActive: true,
      isDoctor: true,
      isSecretary: false,
      isSuperadmin: false,
      adminOf: [AdminOf(clientId: 4, clientName: 'Clínica Central')],
    );

    final screen = AuthNavigation.screenForRole('admin', profile);

    expect(screen, isA<AdminPanel>());
    final adminPanel = screen as AdminPanel;
    expect(adminPanel.clientId, 4);
    expect(adminPanel.profile, same(profile));
    expect(
      adminPanel.profile.roles,
      containsAll(['patient', 'doctor', 'admin']),
    );
  });
}
