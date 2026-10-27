import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/core/widgets/error_view.dart';
import 'package:frontend/features/calendar/presentation/providers/public_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/widgets/week_view.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/dialogs/appointment_detail_dialog.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

class PublicCalendarScreen extends ConsumerStatefulWidget {
  final int? doctorId;
  final String? doctorName;
  final void Function(Schedule schedule, DateTime date)? onScheduleTap;

  const PublicCalendarScreen({
    super.key,
    this.doctorId,
    this.doctorName,
    this.onScheduleTap,
  });

  @override
  ConsumerState<PublicCalendarScreen> createState() =>
      _PublicCalendarScreenState();
}

class _PublicCalendarScreenState extends ConsumerState<PublicCalendarScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(_setInitialFilters);
  }

  @override
  void didUpdateWidget(covariant PublicCalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final doctorChanged = oldWidget.doctorId != widget.doctorId;
    if (doctorChanged) {
      Future.microtask(_setInitialFilters);
    }
  }

  void _setInitialFilters() {
    ref
        .read(publicCalendarFilterProvider.notifier)
        .setInitialFilters(doctorId: widget.doctorId, clinicId: null);
  }

  void _openAppointmentDetail(Appointment appointment) {
    showAppointmentDetailSheet(
      context: context,
      appointment: appointment,
      onCancelled: ref.read(publicCalendarNotifierProvider.notifier).refresh,
    );
  }

  void _previousWeek() {
    ref
        .read(publicWeekStartProvider.notifier)
        .update((weekStart) => weekStart.subtract(const Duration(days: 7)));
  }

  void _nextWeek() {
    ref
        .read(publicWeekStartProvider.notifier)
        .update((weekStart) => weekStart.add(const Duration(days: 7)));
  }

  void _openSchedule(Schedule schedule) {
    final weekStart = ref.read(publicWeekStartProvider);
    final date = weekStart.add(Duration(days: schedule.dayOfWeek));
    final today = DateUtils.dateOnly(DateTime.now());

    if (date.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes agendar una cita en el pasado.'),
        ),
      );
      return;
    }

    widget.onScheduleTap?.call(schedule, date);
  }

  @override
  Widget build(BuildContext context) {
    final allAppointmentsAsync = ref.watch(publicCalendarNotifierProvider);
    final weekStart = ref.watch(publicWeekStartProvider);
    final schedulesAsync = ref.watch(publicSchedulesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: _previousWeek,
                icon: const Icon(Icons.chevron_left),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
              IconButton(
                onPressed: _nextWeek,
                icon: const Icon(Icons.chevron_right),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),

        Expanded(
          child: allAppointmentsAsync.when(
            skipError: true,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) {
              final message = error is ApiException
                  ? error.message
                  : 'No se pudo cargar el calendario público.';

              return ErrorView(
                message: message,
                onRetry: ref
                    .read(publicCalendarNotifierProvider.notifier)
                    .refresh,
              );
            },
            data: (appointments) {
              final schedules = schedulesAsync.valueOrNull ?? const [];

              return WeekView(
                weekStart: weekStart,
                appointments: appointments,
                schedules: schedules,
                compact: true,
                showScheduleClinic: true,
                legendLeading: widget.doctorName == null
                    ? null
                    : Text(
                        'Mostrando horario del doctor: ${widget.doctorName}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                onAppointmentTap: _openAppointmentDetail,
                onScheduleTap: _openSchedule,
              );
            },
          ),
        ),
      ],
    );
  }
}
