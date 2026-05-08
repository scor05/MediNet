import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/providers/public_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/widgets/public_calendar/public_calendar_dropdown.dart';

class PublicCalendarFilterBar extends StatelessWidget {
  final List<Appointment> appointments;
  final PublicCalendarFilters filters;
  final ValueChanged<int?> onDoctorChanged;
  final ValueChanged<int?> onClinicChanged;

  const PublicCalendarFilterBar({
    super.key,
    required this.appointments,
    required this.filters,
    required this.onDoctorChanged,
    required this.onClinicChanged,
  });

  Map<int, String> get _doctorOptions {
    final result = <int, String>{};

    for (final appointment in appointments) {
      result[appointment.doctorId] = appointment.doctorName;
    }

    return result;
  }

  Map<int, String> get _clinicOptions {
    final result = <int, String>{};

    for (final appointment in appointments) {
      result[appointment.clinicId] = appointment.clinicName;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final doctorOptions = _doctorOptions;
    final clinicOptions = _clinicOptions;

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
