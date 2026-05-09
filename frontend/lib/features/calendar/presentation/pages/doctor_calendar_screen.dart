import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/utils/logout_helper.dart';
import 'package:frontend/features/auth/domain/entities/user_profile.dart';
import 'package:frontend/features/calendar/presentation/providers/doctor_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/utils/calendar_dialog_helpers.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_app_bar.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_body.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_fab_menu.dart';
import 'package:frontend/features/calendar/presentation/pages/settings_screen.dart';

class DoctorCalendarScreen extends ConsumerStatefulWidget {
  final UserProfile profile;

  const DoctorCalendarScreen({super.key, required this.profile});

  @override
  ConsumerState<DoctorCalendarScreen> createState() =>
      _DoctorCalendarScreenState();
}

class _DoctorCalendarScreenState extends ConsumerState<DoctorCalendarScreen> {
  bool _fabOpen = false;

  void _toggleFab() {
    setState(() => _fabOpen = !_fabOpen);
  }

  void _closeFab() {
    setState(() => _fabOpen = false);
  }

  Future<void> _openCreateAppointment() async {
    _closeFab();

    final weekStart = ref.read(doctorWeekStartProvider);

    final created = await showCreateAppointmentSheet(
      context: context,
      weekStart: weekStart,
    );

    if (created != null) {
      ref.read(doctorCalendarNotifierProvider.notifier).refresh();
    }
  }

  Future<void> _openCreateSchedule() async {
    _closeFab();

    await showCreateScheduleSheet(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(doctorCalendarNotifierProvider);
    final weekStart = ref.watch(doctorWeekStartProvider);

    return Scaffold(
      appBar: CalendarAppBar(
        title: 'Mi Calendario',
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => logoutAndGoToWelcome(context: context, ref: ref),
        ),
        settingsButton: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsScreen(profile: widget.profile),
              ),
            );
          },
        ),
        onPreviousWeek: () => ref
            .read(doctorWeekStartProvider.notifier)
            .update((d) => d.subtract(const Duration(days: 7))),
        onNextWeek: () => ref
            .read(doctorWeekStartProvider.notifier)
            .update((d) => d.add(const Duration(days: 7))),
      ),
      body: Stack(
        children: [
          CalendarBody(
            calendarAsync: calendarAsync,
            weekStart: weekStart,
            onRetry: ref.read(doctorCalendarNotifierProvider.notifier).refresh,
            showPatient: true,
          ),
          if (_fabOpen)
            GestureDetector(
              onTap: _closeFab,
              child: Container(color: Colors.black26),
            ),
          CalendarFabMenu(
            isOpen: _fabOpen,
            onToggle: _toggleFab,
            onCreateAppointment: _openCreateAppointment,
            onCreateSchedule: _openCreateSchedule,
          ),
        ],
      ),
    );
  }
}
