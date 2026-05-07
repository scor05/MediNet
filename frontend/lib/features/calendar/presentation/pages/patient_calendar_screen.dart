import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/utils/logout_helper.dart';
import 'package:frontend/features/calendar/presentation/providers/patient_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_app_bar.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_body.dart';

class PatientCalendarScreen extends ConsumerStatefulWidget {
  const PatientCalendarScreen({super.key});

  @override
  ConsumerState<PatientCalendarScreen> createState() =>
      _PatientCalendarScreenState();
}

class _PatientCalendarScreenState extends ConsumerState<PatientCalendarScreen> {
  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(patientCalendarNotifierProvider);
    final weekStart = ref.watch(patientWeekStartProvider);

    return Scaffold(
      appBar: CalendarAppBar(
        title: 'Mis citas',
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => logoutAndGoToWelcome(context: context, ref: ref),
        ),
        onPreviousWeek: () => ref
            .read(patientWeekStartProvider.notifier)
            .update((d) => d.subtract(const Duration(days: 7))),
        onNextWeek: () => ref
            .read(patientWeekStartProvider.notifier)
            .update((d) => d.add(const Duration(days: 7))),
      ),
      body: CalendarBody(
        calendarAsync: calendarAsync,
        weekStart: weekStart,
        onRetry: ref.read(patientCalendarNotifierProvider.notifier).refresh,
        showDoctor: true,
      ),
    );
  }
}
