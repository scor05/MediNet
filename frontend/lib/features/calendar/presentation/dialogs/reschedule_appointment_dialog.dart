import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/providers/appointment_domain_providers.dart';

Future<bool?> showRescheduleAppointmentDialog({
  required BuildContext context,
  required Appointment appointment,
  DateTime? openedAt,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => RescheduleAppointmentDialog(
      appointment: appointment,
      openedAt: openedAt ?? DateTime.now(),
    ),
  );
}

class RescheduleAppointmentDialog extends ConsumerStatefulWidget {
  final Appointment appointment;
  final DateTime openedAt;

  const RescheduleAppointmentDialog({
    super.key,
    required this.appointment,
    required this.openedAt,
  });

  @override
  ConsumerState<RescheduleAppointmentDialog> createState() =>
      _RescheduleAppointmentDialogState();
}

class _RescheduleAppointmentDialogState
    extends ConsumerState<RescheduleAppointmentDialog> {
  Timer? _validationDebounce;
  int _validationId = 0;
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  bool _checking = false;
  bool _valid = false;
  bool _saving = false;
  String? _error;

  DateTime get _today {
    final now = widget.openedAt;
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    final appointmentDate = DateTime(
      widget.appointment.date.year,
      widget.appointment.date.month,
      widget.appointment.date.day,
    );
    _selectedDate = appointmentDate.isBefore(_today) ? _today : appointmentDate;
    _selectedTime = _parseTime(widget.appointment.startTime);
    WidgetsBinding.instance.addPostFrameCallback((_) => _validate());
  }

  @override
  void dispose() {
    _validationDebounce?.cancel();
    super.dispose();
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = date);
    _scheduleValidation();
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.fromDateTime(widget.openedAt),
      helpText: 'Selecciona la nueva hora',
    );

    if (selected == null || !mounted) return;

    if (_isPast(_selectedDate, selected)) {
      _validationDebounce?.cancel();
      _validationId++;
      setState(() {
        _selectedTime = null;
        _checking = false;
        _valid = false;
        _error = 'No se puede seleccionar una hora pasada.';
      });
      return;
    }

    setState(() => _selectedTime = selected);
    _scheduleValidation();
  }

  void _scheduleValidation() {
    _validationDebounce?.cancel();
    final validationId = ++_validationId;

    setState(() {
      _checking = true;
      _valid = false;
      _error = null;
    });

    _validationDebounce = Timer(
      const Duration(milliseconds: 300),
      () => _validate(validationId: validationId),
    );
  }

  Future<void> _validate({int? validationId}) async {
    final currentValidationId = validationId ?? ++_validationId;
    final time = _selectedTime;

    if (time == null) {
      if (!mounted || currentValidationId != _validationId) return;
      setState(() {
        _checking = false;
        _valid = false;
      });
      return;
    }

    if (_isPast(_selectedDate, time)) {
      if (!mounted || currentValidationId != _validationId) return;
      setState(() {
        _checking = false;
        _valid = false;
        _error = 'No se puede reprogramar a una fecha u hora pasada.';
      });
      return;
    }

    setState(() {
      _checking = true;
      _valid = false;
      _error = null;
    });

    try {
      await ref
          .read(rescheduleAppointmentUsecaseProvider)
          .check(
            appointmentId: widget.appointment.id,
            date: _selectedDate,
            startTime: time,
          );

      if (!mounted || currentValidationId != _validationId) return;
      setState(() {
        _checking = false;
        _valid = true;
      });
    } catch (error) {
      if (!mounted || currentValidationId != _validationId) return;
      setState(() {
        _checking = false;
        _valid = false;
        _error = error is ApiException
            ? error.message
            : 'No se pudo validar el nuevo horario.';
      });
    }
  }

  Future<void> _confirm() async {
    final time = _selectedTime;
    if (!_valid || _saving || time == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref.read(rescheduleAppointmentUsecaseProvider)(
        appointmentId: widget.appointment.id,
        date: _selectedDate,
        startTime: time,
      );

      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _valid = false;
        _error = error is ApiException
            ? error.message
            : 'No se pudo reprogramar la cita.';
      });
    }
  }

  bool _isPast(DateTime date, TimeOfDay time) {
    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final opened = widget.openedAt;
    final openedMinute = DateTime(
      opened.year,
      opened.month,
      opened.day,
      opened.hour,
      opened.minute,
    );

    return selected.isBefore(openedMinute);
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Seleccionar hora';
    return time.format(context);
  }

  @override
  Widget build(BuildContext context) {
    final lastDate = DateTime(_today.year + 2, 12, 31);

    return AlertDialog(
      title: const Text('Reprogramar cita'),
      content: SizedBox(
        width: 430,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: _today,
                lastDate: lastDate,
                onDateChanged: _selectDate,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _saving ? null : _pickTime,
                icon: const Icon(Icons.schedule),
                label: Text(_formatTime(_selectedTime)),
              ),
              const SizedBox(height: 12),
              if (_checking) const LinearProgressIndicator(),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: _valid && !_checking && !_saving ? _confirm : null,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirmar reprogramación'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
