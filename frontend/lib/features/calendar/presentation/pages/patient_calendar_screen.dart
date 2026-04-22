import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/calendar/presentation/providers/patient_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/widgets/week_view.dart';

class PatientCalendarScreen extends ConsumerWidget {
  const PatientCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarAsync = ref.watch(patientCalendarNotifierProvider);
    final weekStart = ref.watch(patientWeekStartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis citas'),
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
      body: calendarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e is ApiException ? e.message : 'Error inesperado.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: ref
                    .read(patientCalendarNotifierProvider.notifier)
                    .refresh,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (appointments) => appointments.isEmpty
            ? const Center(
                child: Text(
                  'No tienes citas esta semana.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : WeekView(
                weekStart: weekStart,
                appointments: appointments,
                showDoctor: true,
              ),
      ),
    );
  }
}
