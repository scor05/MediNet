import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/calendar/presentation/providers/doctor_calendar_provider.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

class BlockScheduleDialog extends ConsumerStatefulWidget {
  const BlockScheduleDialog({super.key});

  @override
  ConsumerState<BlockScheduleDialog> createState() =>
      _BlockScheduleDialogState();
}

class _BlockScheduleDialogState extends ConsumerState<BlockScheduleDialog> {
  DateTime? _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 0);

  List<Schedule> _allSchedules = [];
  List<Schedule> _schedulesForDay = [];
  Schedule? _selectedSchedule;

  bool _loadingSchedules = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    setState(() {
      _loadingSchedules = true;
      _error = null;
    });
    try {
      final schedules = await ref
          .read(doctorCalendarNotifierProvider.notifier)
          .getDoctorSchedules();
      if (!mounted) return;
      setState(() {
        _allSchedules = schedules;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : 'Error al cargar horarios.';
      });
    } finally {
      if (mounted) setState(() => _loadingSchedules = false);
    }
  }

  void _onDateChanged(DateTime date) {
    // dayOfWeek en el backend: 0=Lunes ... 6=Domingo
    // Flutter weekday: 1=Monday ... 7=Sunday
    final dow = date.weekday - 1;
    final filtered =
        _allSchedules.where((s) => s.dayOfWeek == dow).toList();
    setState(() {
      _selectedDate = date;
      _schedulesForDay = filtered;
      _selectedSchedule = filtered.length == 1 ? filtered.first : null;
      _error = null;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) _onDateChanged(picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        _error = null;
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  bool _isValidRange() {
    final s = _startTime.hour * 60 + _startTime.minute;
    final e = _endTime.hour * 60 + _endTime.minute;
    return e > s;
  }

  Future<void> _submit() async {
    if (_selectedDate == null) {
      setState(() => _error = 'Selecciona una fecha.');
      return;
    }
    if (_schedulesForDay.isEmpty) {
      setState(() => _error = 'No tienes horario para el día seleccionado.');
      return;
    }
    if (_selectedSchedule == null) {
      setState(() => _error = 'Selecciona un horario.');
      return;
    }
    if (!_isValidRange()) {
      setState(
        () => _error = 'La hora de inicio debe ser anterior a la de fin.',
      );
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref
          .read(doctorCalendarNotifierProvider.notifier)
          .createBlockade(
            scheduleId: _selectedSchedule!.id,
            date: _selectedDate!,
            startTime: _startTime,
            endTime: _endTime,
          );

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horario bloqueado exitosamente')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (e is ApiException) {
          _error = e.message;
        } else {
          String msg = e.toString();
          if (msg.startsWith('Exception: ')) msg = msg.substring(11);
          _error = msg.isEmpty ? 'Ocurrió un error inesperado.' : msg;
        }
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Bloquear horario',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          if (_loadingSchedules)
            const Center(child: CircularProgressIndicator())
          else ...[
            // Date picker
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  suffixIcon: Icon(Icons.calendar_today, size: 18),
                ),
                child: Text(
                  _selectedDate != null
                      ? _fmtDate(_selectedDate!)
                      : 'Seleccionar fecha',
                  style: _selectedDate == null
                      ? TextStyle(color: Colors.grey.shade500)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Schedule selector (only when multiple schedules match the day)
            if (_selectedDate != null && _schedulesForDay.length > 1) ...[
              DropdownButtonFormField<Schedule>(
                value: _selectedSchedule,
                decoration: const InputDecoration(labelText: 'Horario / Clínica'),
                items: _schedulesForDay
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.clinicName),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedSchedule = v;
                  _error = null;
                }),
              ),
              const SizedBox(height: 10),
            ],

            if (_selectedDate != null && _schedulesForDay.length == 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Clínica: ${_selectedSchedule!.clinicName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),

            // Time range
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickTime(true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Hora inicio',
                      ),
                      child: Text(_fmt(_startTime)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickTime(false),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Hora fin'),
                      child: Text(_fmt(_endTime)),
                    ),
                  ),
                ),
              ],
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Bloquear'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
