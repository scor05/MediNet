import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/calendar/domain/usecases/get_public_doctors_usecase.dart';
import 'package:frontend/features/calendar/domain/providers/public_calendar_domain_providers.dart';
import 'package:frontend/features/calendar/presentation/providers/secretary_calendar_provider.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/user/domain/entities/user.dart';

class BlockScheduleSecretaryDialog extends ConsumerStatefulWidget {
  const BlockScheduleSecretaryDialog({super.key});

  @override
  ConsumerState<BlockScheduleSecretaryDialog> createState() =>
      _BlockScheduleSecretaryDialogState();
}

class _BlockScheduleSecretaryDialogState
    extends ConsumerState<BlockScheduleSecretaryDialog> {
  // Doctors
  List<User> _doctors = [];
  User? _selectedDoctor;
  bool _loadingDoctors = true;

  // Schedules
  List<Schedule> _allSchedules = [];
  List<Schedule> _schedulesForDay = [];
  Schedule? _selectedSchedule;
  bool _loadingSchedules = false;

  // Form
  DateTime? _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 0);

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    setState(() {
      _loadingDoctors = true;
      _error = null;
    });
    try {
      final doctors =
          await ref.read(getPublicDoctorsUsecaseProvider).call();
      if (!mounted) return;
      setState(() => _doctors = doctors);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : 'Error al cargar doctores.';
      });
    } finally {
      if (mounted) setState(() => _loadingDoctors = false);
    }
  }

  Future<void> _onDoctorChanged(User? doctor) async {
    if (doctor == null) return;
    setState(() {
      _selectedDoctor = doctor;
      _allSchedules = [];
      _schedulesForDay = [];
      _selectedSchedule = null;
      _selectedDate = null;
      _loadingSchedules = true;
      _error = null;
    });
    try {
      final schedules = await ref
          .read(secretaryCalendarNotifierProvider.notifier)
          .getSchedulesByDoctorId(doctor.id);
      if (!mounted) return;
      setState(() => _allSchedules = schedules);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error =
            e is ApiException ? e.message : 'Error al cargar horarios.';
      });
    } finally {
      if (mounted) setState(() => _loadingSchedules = false);
    }
  }

  void _onDateChanged(DateTime date) {
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
    if (_selectedDoctor == null) {
      setState(() => _error = 'Selecciona un doctor.');
      return;
    }
    if (_selectedDate == null) {
      setState(() => _error = 'Selecciona una fecha.');
      return;
    }
    if (_schedulesForDay.isEmpty) {
      setState(
        () => _error = 'El doctor no tiene horario para el día seleccionado.',
      );
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
          .read(secretaryCalendarNotifierProvider.notifier)
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

          if (_loadingDoctors)
            const Center(child: CircularProgressIndicator())
          else ...[
            // Doctor selector
            DropdownButtonFormField<User>(
              value: _selectedDoctor,
              decoration: const InputDecoration(labelText: 'Doctor'),
              items: _doctors
                  .map(
                    (d) => DropdownMenuItem(value: d, child: Text(d.name)),
                  )
                  .toList(),
              onChanged: _onDoctorChanged,
            ),
            const SizedBox(height: 10),

            if (_loadingSchedules)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_selectedDoctor != null) ...[
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

              // Schedule selector (multiple clinics same day)
              if (_selectedDate != null && _schedulesForDay.length > 1) ...[
                DropdownButtonFormField<Schedule>(
                  value: _selectedSchedule,
                  decoration: const InputDecoration(
                    labelText: 'Horario / Clínica',
                  ),
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
                        decoration: const InputDecoration(
                          labelText: 'Hora fin',
                        ),
                        child: Text(_fmt(_endTime)),
                      ),
                    ),
                  ),
                ],
              ),
            ],

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
