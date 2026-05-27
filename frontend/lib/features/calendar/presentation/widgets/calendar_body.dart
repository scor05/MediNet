import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/core/widgets/error_view.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/widgets/week_view.dart';
import 'package:frontend/features/calendar/presentation/providers/doctor_calendar_provider.dart';

class CalendarBody extends ConsumerStatefulWidget {
  final AsyncValue<List<Appointment>> calendarAsync;
  final DateTime weekStart;
  final VoidCallback onRetry;
  final bool showDoctor;
  final bool showPatient;
  final bool showSchedules;
  final void Function(Appointment)? onBlockadeTap;

  const CalendarBody({
    super.key,
    required this.calendarAsync,
    required this.weekStart,
    required this.onRetry,
    this.showDoctor = false,
    this.showPatient = false,
    this.showSchedules = false,
    this.onBlockadeTap,
  });

  @override
  ConsumerState<CalendarBody> createState() => _CalendarBodyState();
}

class _CalendarBodyState extends ConsumerState<CalendarBody> {
  @override
  Widget build(BuildContext context) {
    final schedulesAsync = widget.showSchedules
        ? ref.watch(doctorSchedulesProvider)
        : const AsyncValue.data([]);

    return schedulesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),

      error: (e, _) => ErrorView(
        message: e is ApiException
            ? e.message
            : 'Error cargando horarios.',
        onRetry: widget.onRetry,
      ),

      data: (schedules) {
        return widget.calendarAsync.when(
          skipLoadingOnReload: true,

          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),

          error: (e, _) => ErrorView(
            message: e is ApiException
                ? e.message
                : 'Error inesperado.',
            onRetry: widget.onRetry,
          ),

          data: (appointments) => Stack(
            children: [
              WeekView(
                weekStart: widget.weekStart,
                appointments: appointments,
                schedules: schedules,
                showDoctor: widget.showDoctor,
                showPatient: widget.showPatient,
                onBlockadeTap: widget.onBlockadeTap,
              ),

              if (widget.calendarAsync.isLoading)
                const LinearProgressIndicator(minHeight: 3),
            ],
          ),
        );
      },
    );
  }
}
