import 'package:flutter/material.dart';

class ScheduleConfirmationDialog extends StatelessWidget {
  final String doctor;
  final String clinic;
  final List<String> days;
  final String startTime;
  final String endTime;
  final int duration;
  final List<String> intervals;

  const ScheduleConfirmationDialog({
    super.key,
    required this.doctor,
    required this.clinic,
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.intervals,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        days.length == 1 ? 'Confirmar horario' : 'Confirmar horarios',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Revisa los datos antes de guardar.'),
            const SizedBox(height: 16),
            _SummaryItem(
              label: 'Doctor',
              value: doctor,
              valueKey: const ValueKey('schedule-confirmation-doctor'),
            ),
            _SummaryItem(
              label: 'Clínica',
              value: clinic,
              valueKey: const ValueKey('schedule-confirmation-clinic'),
            ),
            _SummaryItem(
              label: 'Días',
              value: days.join(', '),
              valueKey: const ValueKey('schedule-confirmation-days'),
            ),
            _SummaryItem(
              label: 'Hora inicial',
              value: startTime,
              valueKey: const ValueKey('schedule-confirmation-start'),
            ),
            _SummaryItem(
              label: 'Hora final',
              value: endTime,
              valueKey: const ValueKey('schedule-confirmation-end'),
            ),
            _SummaryItem(
              label: 'Duración de cada cita',
              value: '$duration minutos',
              valueKey: const ValueKey('schedule-confirmation-duration'),
            ),
            const SizedBox(height: 8),
            Text(
              'Intervalos resultantes',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              intervals.isEmpty
                  ? 'No se generarán intervalos completos.'
                  : intervals.join(', '),
              key: const ValueKey('schedule-confirmation-intervals'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('schedule-confirmation-edit'),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Volver a editar'),
        ),
        FilledButton(
          key: const ValueKey('schedule-confirmation-submit'),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Confirmar y guardar'),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Key? valueKey;

  const _SummaryItem({required this.label, required this.value, this.valueKey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value, key: valueKey)),
        ],
      ),
    );
  }
}
