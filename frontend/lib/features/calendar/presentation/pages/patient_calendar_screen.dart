import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/pages/welcome_screen.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/dialogs/appointment_detail_dialog.dart';
import 'package:frontend/features/calendar/presentation/dialogs/patient_calendar_filter_dialog.dart';
import 'package:frontend/features/calendar/presentation/providers/patient_calendar_filter_provider.dart';
import 'package:frontend/features/calendar/presentation/providers/patient_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_body.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_shell.dart';
import 'package:frontend/features/patient_profile/presentation/pages/patient_profile_screen.dart';
import 'package:frontend/theme/app_theme.dart';

class PatientCalendarScreen extends ConsumerStatefulWidget {
  final int patientId;

  const PatientCalendarScreen({super.key, required this.patientId});

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

  void _openSettings() {
    CalendarShellNavigation.maybeOf(context)?.onOpenSettings();
  }

  void _openAppointmentDetail(Appointment appointment) {
    showAppointmentDetailSheet(
      context: context,
      appointment: appointment,
      onCancelled: ref
          .read(patientCalendarNotifierProvider(widget.patientId).notifier)
          .refresh,
    );
  }

  Future<void> _openFilterDialog() async {
    final currentFilters = ref.read(patientCalendarFilterProvider);

    final result = await showPatientCalendarFilterDialog(
      context: context,
      ref: ref,
      currentFilters: currentFilters,
    );

    if (result == null) return;

    final notifier = ref.read(patientCalendarFilterProvider.notifier);

    if (result.doctorId != null) {
      notifier.setDoctor(result.doctorId!, result.doctorName!);
    } else {
      notifier.clearDoctor();
    }

    if (result.clinicId != null) {
      notifier.setClinic(result.clinicId!, result.clinicName!);
    } else {
      notifier.clearClinic();
    }
  }

  List<Appointment> _applyFilters(
    List<Appointment> appointments,
    PatientCalendarFilterState filters,
  ) {
    if (!filters.hasFilters) return appointments;

    return appointments.where((a) {
      if (filters.doctorId != null && a.doctorId != filters.doctorId) {
        return false;
      }
      if (filters.clinicId != null && a.clinicId != filters.clinicId) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(
      patientCalendarNotifierProvider(widget.patientId),
    );
    final weekStart = ref.watch(patientWeekStartProvider);
    final filters = ref.watch(patientCalendarFilterProvider);

    final filteredAsync = calendarAsync.whenData(
      (appointments) => _applyFilters(appointments, filters),
    );

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
            icon: const Icon(Icons.settings),
            tooltip: 'Ajustes',
            onPressed: _openSettings,
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_alt_outlined),
                  tooltip: 'Filtrar',
                  onPressed: _openFilterDialog,
                ),
                if (filters.hasFilters)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
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
        calendarAsync: filteredAsync,
        weekStart: weekStart,
        onRetry: ref
            .read(patientCalendarNotifierProvider(widget.patientId).notifier)
            .refresh,
        showDoctor: true,
        onAppointmentTap: _openAppointmentDetail,
      ),
    );
  }
}

