import 'package:flutter/material.dart';
import 'package:frontend/features/calendar/presentation/providers/patient_calendar_filter_provider.dart';
import 'package:frontend/features/calendar/presentation/providers/staff_calendar_filter_provider.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_item_legend.dart';

class CalendarFilterSummary extends StatelessWidget
    implements CalendarLegendLeading {
  final VoidCallback onOpenFilters;
  final List<_ActiveCalendarFilter> _filters;

  const CalendarFilterSummary._({
    required this.onOpenFilters,
    required List<_ActiveCalendarFilter> filters,
  }) : _filters = filters;

  factory CalendarFilterSummary.forPatient({
    required PatientCalendarFilterState filters,
    required ValueChanged<PatientCalendarFilterState> onChanged,
    required VoidCallback onOpenFilters,
  }) {
    final active = <_ActiveCalendarFilter>[];

    if (filters.doctorId != null) {
      active.add(
        _ActiveCalendarFilter(
          label: 'Doctor: ${_displayName(filters.doctorName)}',
          onDeleted: () => onChanged(filters.copyWith(clearDoctor: true)),
        ),
      );
    }
    if (filters.clinicId != null) {
      active.add(
        _ActiveCalendarFilter(
          label: 'Clínica: ${_displayName(filters.clinicName)}',
          onDeleted: () => onChanged(filters.copyWith(clearClinic: true)),
        ),
      );
    }
    if (!filters.showCancelled) {
      active.add(
        _ActiveCalendarFilter(
          label: 'Ocultar canceladas',
          onDeleted: () => onChanged(filters.copyWith(showCancelled: true)),
        ),
      );
    }

    return CalendarFilterSummary._(
      onOpenFilters: onOpenFilters,
      filters: active,
    );
  }

  factory CalendarFilterSummary.forStaff({
    required StaffCalendarFilterState filters,
    required ValueChanged<StaffCalendarFilterState> onChanged,
    required VoidCallback onOpenFilters,
    required bool showDoctorFilter,
  }) {
    final active = <_ActiveCalendarFilter>[];

    if (filters.patientId != null) {
      active.add(
        _ActiveCalendarFilter(
          label: 'Paciente: ${_displayName(filters.patientName)}',
          onDeleted: () => onChanged(filters.copyWith(clearPatient: true)),
        ),
      );
    }
    if (showDoctorFilter && filters.filterDoctor && filters.doctorId != null) {
      active.add(
        _ActiveCalendarFilter(
          label: 'Doctor: ${_displayName(filters.doctorName)}',
          onDeleted: () => onChanged(filters.copyWith(clearDoctor: true)),
        ),
      );
    }
    if (filters.filterClinic && filters.clinicId != null) {
      active.add(
        _ActiveCalendarFilter(
          label: 'Clínica: ${_displayName(filters.clinicName)}',
          onDeleted: () => onChanged(filters.copyWith(clearClinic: true)),
        ),
      );
    }
    if (filters.startTime != null) {
      active.add(
        _ActiveCalendarFilter(
          label: 'Desde: ${_shortTime(filters.startTime!)}',
          onDeleted: () => onChanged(filters.copyWith(clearStartTime: true)),
        ),
      );
    }
    if (filters.endTime != null) {
      active.add(
        _ActiveCalendarFilter(
          label: 'Hasta: ${_shortTime(filters.endTime!)}',
          onDeleted: () => onChanged(filters.copyWith(clearEndTime: true)),
        ),
      );
    }
    if (!filters.showSchedules) {
      active.add(
        _ActiveCalendarFilter(
          label: 'Ocultar horarios',
          onDeleted: () => onChanged(filters.copyWith(showSchedules: true)),
        ),
      );
    }
    if (!filters.showBlockades) {
      active.add(
        _ActiveCalendarFilter(
          label: 'Ocultar bloqueos',
          onDeleted: () => onChanged(filters.copyWith(showBlockades: true)),
        ),
      );
    }
    if (!filters.showAppointments) {
      active.add(
        _ActiveCalendarFilter(
          label: 'Ocultar citas',
          onDeleted: () => onChanged(filters.copyWith(showAppointments: true)),
        ),
      );
    }
    if (!filters.showCancelled) {
      active.add(
        _ActiveCalendarFilter(
          label: 'Ocultar canceladas',
          onDeleted: () => onChanged(filters.copyWith(showCancelled: true)),
        ),
      );
    }

    return CalendarFilterSummary._(
      onOpenFilters: onOpenFilters,
      filters: active,
    );
  }

  static String _displayName(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? 'Seleccionado' : trimmed;
  }

  static String _shortTime(String value) =>
      value.length >= 5 ? value.substring(0, 5) : value;

  @override
  bool get hasExpandedContent => _filters.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          key: const ValueKey('calendar-filter-button'),
          tooltip: 'Filtrar',
          color: Colors.black,
          icon: const Icon(Icons.filter_alt_outlined),
          onPressed: onOpenFilters,
        ),
        if (_filters.isNotEmpty) ...[
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtros activos',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _filters
                      .map(
                        (filter) => Chip(
                          key: ValueKey(
                            'active-calendar-filter-${filter.label}',
                          ),
                          label: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 190),
                            child: Text(
                              filter.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: filter.onDeleted,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ActiveCalendarFilter {
  final String label;
  final VoidCallback onDeleted;

  const _ActiveCalendarFilter({required this.label, required this.onDeleted});
}
