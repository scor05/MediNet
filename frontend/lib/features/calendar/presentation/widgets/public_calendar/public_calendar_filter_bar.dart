import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/providers/public_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/widgets/public_calendar/public_calendar_dropdown.dart';

class PublicCalendarFilterBar extends StatelessWidget {
  final List<Appointment> appointments;
  final PublicCalendarFilters filters;
  final int? lockedDoctorId;
  final int? lockedClinicId;
  final ValueChanged<int?> onDoctorChanged;
  final ValueChanged<int?> onClinicChanged;

  const PublicCalendarFilterBar({
    super.key,
    required this.appointments,
    required this.filters,
    required this.onDoctorChanged,
    required this.onClinicChanged,
    this.lockedDoctorId,
    this.lockedClinicId,
  });

  Map<int, String> get _doctorOptions {
    if (lockedDoctorId != null) return {};
    final result = <int, String>{};
    for (final a in appointments) {
      if (lockedClinicId == null || a.clinicId == lockedClinicId) {
        result[a.doctorId] = a.doctorName;
      }
    }
    return result;
  }

  Map<int, String> get _clinicOptions {
    if (lockedClinicId != null) return {};

    final result = <int, String>{};
    for (final a in appointments) {
      if (lockedDoctorId == null || a.doctorId == lockedDoctorId) {
        result[a.clinicId] = a.clinicName;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final doctorOptions = _doctorOptions;
    final clinicOptions = _clinicOptions;

    final showDoctorFilter = doctorOptions.length > 1;
    final showClinicFilter = clinicOptions.length > 1;

    if (!showDoctorFilter && !showClinicFilter) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: PublicCalendarDropdown(
              label: 'Doctor',
              value: filters.doctorId,
              allLabel: 'Todos',
              options: doctorOptions,
              onChanged: onDoctorChanged,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PublicCalendarDropdown(
              label: 'Clínica',
              value: filters.clinicId,
              allLabel: 'Todas',
              options: clinicOptions,
              onChanged: onClinicChanged,
            ),
          ),
        ],
      ),
    );
  }
}
