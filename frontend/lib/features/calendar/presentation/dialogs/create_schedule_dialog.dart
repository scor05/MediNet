import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/calendar/presentation/providers/doctor_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/providers/secretary_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/utils/schedule_duration_validation.dart';
import 'package:frontend/features/calendar/presentation/widgets/schedule_confirmation_dialog.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';
import 'package:frontend/features/clinic/domain/providers/clinic_domain_providers.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/schedule/domain/providers/schedule_domain_providers.dart';
import 'package:frontend/features/calendar/presentation/widgets/existing_schedules_panel.dart';
import 'package:frontend/features/calendar/presentation/widgets/search_selection_status.dart';
import 'package:frontend/features/search/presentation/providers/search_form_provider.dart';
import 'package:frontend/features/search/presentation/widgets/search_input_field.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';
import 'package:frontend/theme/app_theme.dart';

class CreateScheduleDialog extends ConsumerStatefulWidget {
  final bool forSecretary;

  const CreateScheduleDialog({super.key, this.forSecretary = false});

  @override
  ConsumerState<CreateScheduleDialog> createState() =>
      _CreateScheduleDialogState();
}

class _CreateScheduleDialogState extends ConsumerState<CreateScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _doctorCtrl = TextEditingController();
  List<Clinic> _clinics = [];
  int? _selectedClinic;
  final Set<int> _selectedDays = {};
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 16, minute: 0);
  final _durationCtrl = TextEditingController();

  List<Schedule> _existingSchedules = const [];
  bool _loadingExisting = false;
  String? _existingError;
  int _existingRequestId = 0;

  bool _loadingClinics = true;
  bool _saving = false;
  String? _error;

  static const _days = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  static const _unselectedDayColor = Color.fromRGBO(210, 210, 210, 1);

  @override
  void initState() {
    super.initState();
    _durationCtrl.text = '30';
    _fetchClinics();
  }

  @override
  void dispose() {
    _doctorCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  void _selectDoctor(DoctorSearchResult doctor) {
    _doctorCtrl.value = TextEditingValue(
      text: doctor.name,
      selection: TextSelection.collapsed(offset: doctor.name.length),
    );
    ref.read(searchFormNotifierProvider.notifier).selectDoctor(doctor);
    setState(() => _error = null);
  }

  void _clearDoctor() {
    _doctorCtrl.clear();
    final notifier = ref.read(searchFormNotifierProvider.notifier);
    notifier.clearDoctor();
    notifier.showDoctorSuggestions();
    setState(() => _error = null);
  }

  Future<void> _fetchClinics() async {
    setState(() {
      _loadingClinics = true;
      _error = null;
    });

    try {
      final clinics = await ref.read(getClinicsUsecaseProvider).call(null);

      if (!mounted) return;

      setState(() {
        _clinics = clinics;
        if (_clinics.isNotEmpty) _selectedClinic = _clinics.first.id;
      });
      _loadExistingSchedules();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _clinics = [];
        _selectedClinic = null;
        _error = e is ApiException ? e.message : 'Ocurrió un error inesperado.';
      });
    } finally {
      if (mounted) setState(() => _loadingClinics = false);
    }
  }

  /// Consulta los horarios que el doctor ya tiene en la clínica elegida.
  /// Para la secretaria hace falta un doctor seleccionado; el doctor consulta
  /// los suyos.
  Future<void> _loadExistingSchedules() async {
    final requestId = ++_existingRequestId;
    final clinicId = _selectedClinic;
    final doctorId = widget.forSecretary
        ? ref.read(searchFormNotifierProvider).selectedDoctor?.id
        : null;

    if (clinicId == null || (widget.forSecretary && doctorId == null)) {
      setState(() {
        _existingSchedules = const [];
        _existingError = null;
        _loadingExisting = false;
      });
      return;
    }

    setState(() {
      _loadingExisting = true;
      _existingError = null;
    });

    try {
      final schedules = widget.forSecretary
          ? await ref
                .read(getSchedulesByDoctorIdUsecaseProvider)
                .call(doctorId!)
          : await ref.read(getDoctorSchedulesUsecaseProvider).call();
      if (!mounted || requestId != _existingRequestId) return;
      setState(() {
        _existingSchedules = schedules
            .where((schedule) => schedule.clinicId == clinicId)
            .toList();
      });
    } catch (_) {
      if (!mounted || requestId != _existingRequestId) return;
      setState(() {
        _existingSchedules = const [];
        _existingError = 'No se pudieron cargar los horarios existentes.';
      });
    } finally {
      if (mounted && requestId == _existingRequestId) {
        setState(() => _loadingExisting = false);
      }
    }
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

  String _existingSubtitle(String? doctorName) {
    String? clinicName;
    for (final clinic in _clinics) {
      if (clinic.id == _selectedClinic) clinicName = clinic.name;
    }
    return [
      if (widget.forSecretary && doctorName != null) doctorName,
      ?clinicName,
    ].join(' · ');
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  bool _isValidRange() {
    final startMins = _startTime.hour * 60 + _startTime.minute;
    final endMins = _endTime.hour * 60 + _endTime.minute;
    return endMins > startMins;
  }

  String? _intervalPreview() {
    final intervals = _resultingIntervals();
    if (intervals.isEmpty) return null;

    final visibleIntervals = intervals.take(4).toList();
    return '*Intervalos a crearse: ${visibleIntervals.join(', ')}'
        '${intervals.length > visibleIntervals.length ? ', ...' : ''}';
  }

  List<String> _resultingIntervals() {
    final duration = int.tryParse(_durationCtrl.text.trim());
    if (duration == null || duration < 5 || !_isValidRange()) return const [];

    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    final intervals = <String>[];
    var intervalStart = startMinutes;

    while (intervalStart + duration <= endMinutes) {
      final intervalEnd = intervalStart + duration;
      intervals.add(
        '${_formatMinutes(intervalStart)} - ${_formatMinutes(intervalEnd)}',
      );
      intervalStart = intervalEnd;
    }

    return intervals;
  }

  String _formatMinutes(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  void _toggleDay(int day) {
    setState(() {
      if (!_selectedDays.add(day)) _selectedDays.remove(day);
      _error = null;
    });
  }

  String _errorMessage(Object error) {
    if (error is ApiException) return error.message;
    var message = error.toString();
    if (message.startsWith('Exception: ')) message = message.substring(11);
    return message.isEmpty ? 'Ocurrió un error inesperado.' : message;
  }

  String _selectedClinicName() {
    for (final clinic in _clinics) {
      if (clinic.id == _selectedClinic) return clinic.name;
    }
    return 'Clínica seleccionada';
  }

  String _doctorName(DoctorSearchResult? selectedDoctor) {
    if (widget.forSecretary) return selectedDoctor!.name;

    final authState = ref.read(authNotifierProvider);
    if (authState is AuthAuthenticated) return authState.profile.name;
    return 'Doctor actual';
  }

  Future<bool> _confirmCreation({
    required DoctorSearchResult? selectedDoctor,
    required List<int> requestedDays,
    required int duration,
  }) async {
    FocusScope.of(context).unfocus();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ScheduleConfirmationDialog(
        doctor: _doctorName(selectedDoctor),
        clinic: _selectedClinicName(),
        days: requestedDays.map((day) => _days[day]).toList(),
        startTime: _fmt(_startTime),
        endTime: _fmt(_endTime),
        duration: duration,
        intervals: _resultingIntervals(),
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDays.isEmpty) {
      setState(() => _error = 'Selecciona al menos un día de la semana.');
      return;
    }

    final selectedDoctor = ref.read(searchFormNotifierProvider).selectedDoctor;
    if (widget.forSecretary && selectedDoctor == null) {
      setState(() => _error = 'Selecciona un doctor.');
      return;
    }

    if (_selectedClinic == null) {
      setState(() => _error = 'Selecciona una clínica.');
      return;
    }

    if (!_isValidRange()) {
      setState(
        () => _error = 'La hora de inicio debe ser anterior a la de fin.',
      );
      return;
    }

    final requestedDays = _selectedDays.toList()..sort();
    final duration = int.parse(_durationCtrl.text.trim());
    final confirmed = await _confirmCreation(
      selectedDoctor: selectedDoctor,
      requestedDays: requestedDays,
      duration: duration,
    );
    if (!mounted || !confirmed) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final createSchedule = ref.read(createScheduleUsecaseProvider);
      final createdSchedules = await createSchedule.callMany(
        doctorId: widget.forSecretary ? selectedDoctor!.id : null,
        clinicId: _selectedClinic!,
        daysOfWeek: requestedDays,
        startTime: _startTime,
        endTime: _endTime,
        duration: duration,
      );
      var confirmationText = createdSchedules.length == 1
          ? 'Horario creado exitosamente'
          : '${createdSchedules.length} horarios creados exitosamente';
      if (selectedDoctor != null && widget.forSecretary) {
        confirmationText = createdSchedules.length == 1
            ? 'Horario creado exitosamente para el doctor ${selectedDoctor.name}'
            : '${createdSchedules.length} horarios creados exitosamente para el doctor ${selectedDoctor.name}';
      }

      if (widget.forSecretary) {
        await ref.read(secretarySchedulesNotifierProvider.notifier).refresh();
      } else {
        ref.invalidate(doctorSchedulesProvider);
      }

      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(confirmationText)));
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _errorMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchFormNotifierProvider);
    ref.listen(
      searchFormNotifierProvider.select((state) => state.selectedDoctor?.id),
      (previous, next) {
        if (previous != next) _loadExistingSchedules();
      },
    );
    final searchNotifier = ref.read(searchFormNotifierProvider.notifier);
    final canSubmit =
        !_saving &&
        _selectedDays.isNotEmpty &&
        !_loadingClinics &&
        _selectedClinic != null &&
        (!widget.forSecretary || searchState.selectedDoctor != null);

    return SingleChildScrollView(
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
            Text(
              'Nuevo horario',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            if (_loadingClinics)
              const Center(child: CircularProgressIndicator())
            else if (_error != null && _clinics.isEmpty)
              Center(
                child: Column(
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _fetchClinics,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            else ...[
              Text(
                'Días de la semana',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              Row(
                children: List.generate(7, (day) {
                  final selected = _selectedDays.contains(day);
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: day == 6 ? 0 : 3),
                      child: Semantics(
                        button: true,
                        selected: selected,
                        label: _days[day],
                        child: OutlinedButton(
                          key: ValueKey('schedule-day-$day'),
                          onPressed: _saving ? null : () => _toggleDay(day),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 42),
                            padding: EdgeInsets.zero,
                            backgroundColor: selected
                                ? AppTheme.primary
                                : _unselectedDayColor,
                            foregroundColor: selected
                                ? Colors.white
                                : Color.fromRGBO(100, 100, 100, 1),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            _days[day],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              if (widget.forSecretary) ...[
                SearchSelectionStatus(
                  keyPrefix: 'schedule-doctor',
                  selectedLabel: searchState.selectedDoctor == null
                      ? null
                      : 'Doctor seleccionado: ${searchState.selectedDoctor!.name}',
                  hasTypedText: _doctorCtrl.text.trim().isNotEmpty,
                  prompt: 'Selecciona un doctor de la lista',
                  typedHint:
                      'Lo que escribiste todavía no es un doctor seleccionado.',
                  child: SearchInputField<DoctorSearchResult>(
                    controller: _doctorCtrl,
                    label: 'Doctor',
                    hintText: 'Nombre o especialidad del doctor',
                    loading: searchState.loadingDoctors,
                    selectedItem: searchState.selectedDoctor,
                    results: searchState.doctorResults,
                    titleBuilder: (doctor) => doctor.name,
                    subtitleBuilder: (doctor) => doctor.specialty,
                    onChanged: (query) {
                      searchNotifier.onDoctorQueryChanged(query);
                      setState(() {});
                    },
                    onSelected: _selectDoctor,
                    onClear: _clearDoctor,
                    onEmptyFocus: searchNotifier.showDoctorSuggestions,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              DropdownButtonFormField<int>(
                initialValue: _selectedClinic,
                decoration: const InputDecoration(labelText: 'Clínica'),
                items: _clinics
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedClinic = v;
                    _error = null;
                  });
                  _loadExistingSchedules();
                },
                validator: (v) => v == null ? 'Selecciona una clínica' : null,
              ),
              const SizedBox(height: 10),

              if (_selectedClinic != null &&
                  (!widget.forSecretary ||
                      searchState.selectedDoctor != null)) ...[
                ExistingSchedulesPanel(
                  schedules: _existingSchedules,
                  loading: _loadingExisting,
                  error: _existingError,
                  subtitle: _existingSubtitle(searchState.selectedDoctor?.name),
                ),
                const SizedBox(height: 10),
              ],

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTime(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hora inicio',
                        ),
                        child: Text(
                          _fmt(_startTime),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
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
                        child: Text(
                          _fmt(_endTime),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _durationCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duración de cada cita',
                  suffixText: 'min',
                  helperText: scheduleDurationHelpText,
                  helperMaxLines: 2,
                ),
                validator: (value) => validateScheduleDuration(
                  value: value,
                  startTime: _startTime,
                  endTime: _endTime,
                ),
                onChanged: (_) {
                  setState(() => _error = null);
                },
              ),

              if (_intervalPreview() case final preview?) ...[
                const SizedBox(height: 10),
                Text(
                  preview,
                  key: const ValueKey('schedule-interval-preview'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],

              if (widget.forSecretary && searchState.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  searchState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canSubmit ? _submit : null,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar horario'),
              ),
            ),
            if (widget.forSecretary && searchState.selectedDoctor == null) ...[
              const SizedBox(height: 8),
              const Text(
                'Para guardar el horario, selecciona un doctor de la lista '
                'de sugerencias. Escribir el nombre no es suficiente.',
                key: ValueKey('schedule-submit-hint'),
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
