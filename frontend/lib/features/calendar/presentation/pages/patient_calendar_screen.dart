import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/auth/presentation/pages/welcome_screen.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/calendar/domain/entities/public_slot.dart';
import 'package:frontend/features/calendar/presentation/pages/dialogs/public_create_appointment_dialog.dart';
import 'package:frontend/features/calendar/presentation/providers/patient_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/widgets/week_view.dart';
import 'package:frontend/theme/app_theme.dart';

class PatientCalendarScreen extends ConsumerStatefulWidget {
  const PatientCalendarScreen({super.key});

  @override
  ConsumerState<PatientCalendarScreen> createState() =>
      _PatientCalendarScreenState();
}

class _PatientCalendarScreenState extends ConsumerState<PatientCalendarScreen> {
  Future<void> _openCreateAppointment() async {
    final selectedSlot = await showModalBottomSheet<PublicSlot>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const PublicCreateAppointmentDialog(),
    );

    if (selectedSlot != null) {
      ref.read(patientCalendarNotifierProvider.notifier).refresh();
    }
  }

  Future<void> _logout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateAppointment,
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.event_available),
        label: const Text('Agendar cita'),
      ),
    );
  }
}
