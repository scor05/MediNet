import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/core/widgets/error_view.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/widgets/week_view.dart';
import 'package:frontend/features/calendar/presentation/providers/doctor_calendar_provider.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

class CalendarBody extends ConsumerStatefulWidget {
  final AsyncValue<List<Appointment>> calendarAsync;
  final DateTime weekStart;
  final VoidCallback onRetry;
  final bool showDoctor;
  final bool showPatient;
  final bool showSchedules;
  final void Function(Appointment)? onAppointmentTap;
  final void Function(Appointment)? onBlockadeTap;
  final void Function(Schedule)? onScheduleTap;

  const CalendarBody({
    super.key,
    required this.calendarAsync,
    required this.weekStart,
    required this.onRetry,
    this.showDoctor = false,
    this.showPatient = false,
    this.showSchedules = false,
    this.onAppointmentTap,
    this.onBlockadeTap,
    this.onScheduleTap,
  });

  @override
  ConsumerState<CalendarBody> createState() => _CalendarBodyState();
}

class _CalendarBodyState extends ConsumerState<CalendarBody> {
  @override
  Widget build(BuildContext context) {
    final schedulesAsync = widget.showSchedules
        ? ref.watch(doctorSchedulesProvider)
        : const AsyncValue<List<Schedule>>.data([]);

    return schedulesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      error: (e, _) => ErrorView(
        message: e is ApiException ? e.message : 'Error cargando horarios.',
        onRetry: widget.onRetry,
      ),

      data: (schedules) {
        return widget.calendarAsync.when(
          skipLoadingOnReload: true,
          skipError: true,

          loading: () => const Center(child: CircularProgressIndicator()),

          error: (e, _) => ErrorView(
            message: e is ApiException ? e.message : 'Error inesperado.',
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
                onAppointmentTap: widget.onAppointmentTap,
                onBlockadeTap: widget.onBlockadeTap,
                onScheduleTap: widget.onScheduleTap,
              ),

              if (widget.calendarAsync.isLoading)
                const LinearProgressIndicator(minHeight: 3),

              if (widget.calendarAsync.hasError)
                Positioned(
                  left: 12,
                  right: 12,
                  top: 12,
                  child: Material(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'No se pudo actualizar el calendario. '
                        'Los datos anteriores siguen visibles.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
