import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/core/widgets/error_view.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/widgets/week_view.dart';

class CalendarBody extends StatelessWidget {
  final AsyncValue<List<Appointment>> calendarAsync;
  final DateTime weekStart;
  final VoidCallback onRetry;
  final bool showDoctor;
  final bool showPatient;

  const CalendarBody({
    super.key,
    required this.calendarAsync,
    required this.weekStart,
    required this.onRetry,
    this.showDoctor = false,
    this.showPatient = false,
  });

  @override
  Widget build(BuildContext context) {
    return calendarAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        message: e is ApiException ? e.message : 'Error inesperado.',
        onRetry: onRetry,
      ),
      data: (appointments) => WeekView(
        weekStart: weekStart,
        appointments: appointments,
        showDoctor: showDoctor,
        showPatient: showPatient,
      ),
    );
  }
}
