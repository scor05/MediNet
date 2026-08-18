import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/pages/welcome_screen.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/dialogs/appointment_detail_dialog.dart';
import 'package:frontend/features/calendar/presentation/providers/patient_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_body.dart';
import 'package:frontend/features/patient_profile/presentation/pages/patient_profile_screen.dart';

class PatientCalendarScreen extends ConsumerStatefulWidget {
  const PatientCalendarScreen({super.key});

  @override
  ConsumerState<PatientCalendarScreen> createState() =>
      _PatientCalendarScreenState();
}

class _PatientCalendarScreenState extends ConsumerState<PatientCalendarScreen> {
  Future<void> _logout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PatientProfileScreen()),
    );
  }

  void _openAppointmentDetail(Appointment appointment) {
    showAppointmentDetailSheet(
      context: context,
      appointment: appointment,
      onCancelled: ref.read(patientCalendarNotifierProvider.notifier).refresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(patientCalendarNotifierProvider);
    final weekStart = ref.watch(patientWeekStartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis citas'),
        leading: IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Mi perfil',
            onPressed: _goToProfile,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref
                .read(patientWeekStartProvider.notifier)
                .update((d) => d.subtract(const Duration(days: 7))),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => ref
                .read(patientWeekStartProvider.notifier)
                .update((d) => d.add(const Duration(days: 7))),
          ),
        ],
      ),
      body: CalendarBody(
        calendarAsync: calendarAsync,
        weekStart: weekStart,
        onRetry: ref.read(patientCalendarNotifierProvider.notifier).refresh,
        showDoctor: true,
        onAppointmentTap: _openAppointmentDetail,
      ),
    );
  }
}
