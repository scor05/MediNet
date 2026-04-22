import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/calendar/presentation/providers/doctor_calendar_provider.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

class CreateAppointmentDialog extends ConsumerStatefulWidget {
  final DateTime weekStart;
  const CreateAppointmentDialog({super.key, required this.weekStart});

  @override
  ConsumerState<CreateAppointmentDialog> createState() =>
      _CreateAppointmentDialogState();
}

class _CreateAppointmentDialogState
    extends ConsumerState<CreateAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  List<Schedule> _schedules = [];
  Schedule? _selectedSchedule;
  DateTime? _selectedDate;
  String? _selectedTime;
  List<String> _timeSlots = [];
  final _patientCtrl = TextEditingController();
  String _status = 'requested';
  bool _loadingSchedules = true;
  bool _saving = false;
  String? _error;

  static const _statusOptions = [
    ('requested', 'Solicitada'),
    ('accepted', 'Aceptada'),
  ];

  static const _daysFull = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  @override
  void dispose() {
    _patientCtrl.dispose();
    super.dispose();
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
        _schedules = schedules;
        if (_schedules.isNotEmpty) {
          _selectedSchedule = _schedules.first;
          _updateDate(_selectedSchedule!);
          _updateTimeSlots(_selectedSchedule!);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _schedules = [];
        _selectedSchedule = null;
        _selectedDate = null;
        _selectedTime = null;
        _timeSlots = [];
        _error = e is ApiException ? e.message : 'Ocurrió un error inesperado.';
      });
    } finally {
      if (mounted) setState(() => _loadingSchedules = false);
    }
  }

  DateTime _nextDayOfWeek(int dayOfWeek) {
    for (int i = 0; i < 7; i++) {
      final d = widget.weekStart.add(Duration(days: i));
      if ((d.weekday - 1) == dayOfWeek) return d;
    }
    return widget.weekStart;
  }

  void _updateDate(Schedule s) {
    _selectedDate = _nextDayOfWeek(s.dayOfWeek);
  }

  void _updateTimeSlots(Schedule s) {
    final slots = <String>[];
    var parts = s.startTime.split(':');
    int h = int.parse(parts[0]);
    int m = int.parse(parts[1]);
    final eParts = s.endTime.split(':');
    final endMins = int.parse(eParts[0]) * 60 + int.parse(eParts[1]);

    while (h * 60 + m < endMins) {
      slots.add(
        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}',
      );
      m += s.duration;
      if (m >= 60) {
        h += m ~/ 60;
        m = m % 60;
      }
    }

    _timeSlots = slots;
    _selectedTime = slots.isNotEmpty ? slots.first : null;
  }

  void _onScheduleChanged(Schedule? s) {
    if (s == null) return;
    setState(() {
      _error = null;
      _selectedSchedule = s;
      _updateDate(s);
      _updateTimeSlots(s);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSchedule == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      setState(() => _error = 'Completa todos los campos requeridos.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final parts = _selectedTime!.split(':');
      final startTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );

      final created = await ref
          .read(doctorCalendarNotifierProvider.notifier)
          .createAppointment(
            scheduleId: _selectedSchedule!.id,
            date: _selectedDate!,
            startTime: startTime,
            patientName: _patientCtrl.text.trim(),
            status: _status,
          );

      if (!mounted) return;

      Navigator.of(context).pop(created);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita agendada exitosamente')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : 'No se pudo agendar la cita.';
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
      child: Form(
        key: _formKey,
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
            Text('Nueva cita', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),

            if (_loadingSchedules)
              const Center(child: CircularProgressIndicator())
            else if (_error != null && _schedules.isEmpty)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _fetchSchedules,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            else if (_schedules.isEmpty)
              const Text(
                'No tienes horarios activos. Crea uno primero.',
                style: TextStyle(color: Colors.red),
              )
            else ...[
              DropdownButtonFormField<Schedule>(
                initialValue: _selectedSchedule,
                decoration: const InputDecoration(labelText: 'Horario'),
                items: _schedules
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          '${_daysFull[s.dayOfWeek]} · ${s.startTime}–${s.endTime} · ${s.clinicName}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _onScheduleChanged,
                validator: (v) => v == null ? 'Selecciona un horario' : null,
              ),
              const SizedBox(height: 10),

              if (_selectedDate != null)
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Fecha'),
                  child: Text(
                    '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}  (${_daysFull[_selectedSchedule!.dayOfWeek]})',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: _selectedTime,
                decoration: const InputDecoration(labelText: 'Hora de la cita'),
                items: _timeSlots
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedTime = v;
                  _error = null;
                }),
                validator: (v) => v == null ? 'Selecciona una hora' : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _patientCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del paciente',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: _statusOptions
                    .map(
                      (o) => DropdownMenuItem(value: o.$1, child: Text(o.$2)),
                    )
                    .toList(),
                onChanged: (v) => setState(() {
                  _status = v!;
                  _error = null;
                }),
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
                onPressed: (_saving || _schedules.isEmpty) ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Agendar cita'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
