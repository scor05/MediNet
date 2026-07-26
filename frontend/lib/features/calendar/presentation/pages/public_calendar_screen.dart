import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/core/widgets/error_view.dart';
import 'package:frontend/features/calendar/domain/entities/public_slot.dart';
import 'package:frontend/features/calendar/presentation/dialogs/public_create_appointment_dialog.dart';
import 'package:frontend/features/calendar/presentation/providers/public_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/widgets/public_calendar/public_calendar_filter_bar.dart';
import 'package:frontend/features/calendar/presentation/widgets/week_view.dart';

class PublicCalendarScreen extends ConsumerStatefulWidget {
  final int? doctorId;
  final int? clinicId;

  const PublicCalendarScreen({super.key, this.doctorId, this.clinicId});

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
    final clinicChanged = oldWidget.clinicId != widget.clinicId;

    if (doctorChanged || clinicChanged) {
      Future.microtask(_setInitialFilters);
    }
  }

  void _setInitialFilters() {
    ref
        .read(publicCalendarFilterProvider.notifier)
        .setInitialFilters(
          doctorId: widget.doctorId,
          clinicId: widget.clinicId,
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

  Future<void> _openCreateAppointment() async {
    final filters = ref.read(publicCalendarFilterProvider);

    final selectedSlot = await showModalBottomSheet<PublicSlot>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => PublicCreateAppointmentDialog(
        initialDoctorId: filters.doctorId,
        initialClinicId: filters.clinicId,
      ),
    );

    if (selectedSlot != null) {
      ref.read(publicCalendarNotifierProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final allAppointmentsAsync = ref.watch(publicCalendarNotifierProvider);
    final filters = ref.watch(publicCalendarFilterProvider);
    final weekStart = ref.watch(publicWeekStartProvider);

    return Column(
      children: [
        allAppointmentsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (appointments) {
            return PublicCalendarFilterBar(
              lockedDoctorId: widget.doctorId,
              lockedClinicId: widget.clinicId,
              appointments: appointments,
              filters: filters,
              onDoctorChanged: (doctorId) {
                ref
                    .read(publicCalendarFilterProvider.notifier)
                    .selectDoctor(doctorId);
              },
              onClinicChanged: (clinicId) {
                ref
                    .read(publicCalendarFilterProvider.notifier)
                    .selectClinic(clinicId);
              },
            );
          },
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
          child: Row(
            children: [
              FilledButton.icon(
                onPressed: _openCreateAppointment,
                icon: const Icon(Icons.event_available, size: 18),
                label: const Text('Agendar cita'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const Spacer(),
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
              return WeekView(
                weekStart: weekStart,
                appointments: appointments,
                schedules: const [],
                compact: true,
              );
            },
          ),
        ),
      ],
    );
  }
}
