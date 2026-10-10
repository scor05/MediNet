import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/calendar/presentation/providers/staff_calendar_filter_provider.dart';
import 'package:frontend/features/clinic/domain/entities/clinic_search_result.dart';
import 'package:frontend/features/search/domain/providers/search_domain_providers.dart';
import 'package:frontend/features/search/presentation/widgets/search_input_field.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';
import 'package:frontend/features/user/domain/entities/user.dart';
import 'package:frontend/features/user/domain/providers/user_domain_providers.dart';

Future<StaffCalendarFilterState?> showStaffCalendarFilterDialog({
  required BuildContext context,
  required WidgetRef ref,
  required StaffCalendarFilterState currentFilters,
  required bool allowDoctorFilter,
}) {
  return showDialog<StaffCalendarFilterState>(
    context: context,
    builder: (_) => _StaffCalendarFilterDialog(
      ref: ref,
      initialFilters: currentFilters,
      allowDoctorFilter: allowDoctorFilter,
    ),
  );
}

class _StaffCalendarFilterDialog extends StatefulWidget {
  final WidgetRef ref;
  final StaffCalendarFilterState initialFilters;
  final bool allowDoctorFilter;

  const _StaffCalendarFilterDialog({
    required this.ref,
    required this.initialFilters,
    required this.allowDoctorFilter,
  });

  @override
  State<_StaffCalendarFilterDialog> createState() =>
      _StaffCalendarFilterDialogState();
}

class _StaffCalendarFilterDialogState
    extends State<_StaffCalendarFilterDialog> {
  final _formKey = GlobalKey<FormState>();

  final _patientCtrl = TextEditingController();
  User? _selectedPatient;
  List<User> _patientResults = [];
  bool _loadingPatients = false;
  Timer? _patientDebounce;
  int _patientRequestId = 0;

  bool _doctorEnabled = false;
  final _doctorCtrl = TextEditingController();
  DoctorSearchResult? _selectedDoctor;
  List<DoctorSearchResult> _doctorResults = [];
  bool _loadingDoctors = false;
  Timer? _doctorDebounce;
  int _doctorRequestId = 0;

  bool _clinicEnabled = false;
  final _clinicCtrl = TextEditingController();
  ClinicSearchResult? _selectedClinic;
  List<ClinicSearchResult> _clinicResults = [];
  bool _loadingClinics = false;
  Timer? _clinicDebounce;
  int _clinicRequestId = 0;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _timeError;
  bool _showSchedules = true;
  bool _showBlockades = true;
  bool _showAppointments = true;
  bool _showCancelled = true;
  String? _selectionError;

  @override
  void initState() {
    super.initState();
    final filters = widget.initialFilters;
    _showSchedules = filters.showSchedules;
    _showBlockades = filters.showBlockades;
    _showAppointments = filters.showAppointments;
    _showCancelled = filters.showCancelled;
    _startTime = _parseTime(filters.startTime);
    _endTime = _parseTime(filters.endTime);

    if (filters.patientId != null) {
      _selectedPatient = User(
        id: filters.patientId!,
        name: filters.patientName ?? '',
        email: '',
        phone: '',
        isAccountActive: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
      _patientCtrl.text = filters.patientName ?? '';
    }

    _doctorEnabled = widget.allowDoctorFilter && filters.filterDoctor;
    if (filters.doctorId != null) {
      _selectedDoctor = DoctorSearchResult(
        id: filters.doctorId!,
        name: filters.doctorName ?? '',
        specialty: '',
      );
      _doctorCtrl.text = filters.doctorName ?? '';
    }

    _clinicEnabled = filters.filterClinic;
    if (filters.clinicId != null) {
      _selectedClinic = ClinicSearchResult(
        id: filters.clinicId!,
        name: filters.clinicName ?? '',
        address: '',
      );
      _clinicCtrl.text = filters.clinicName ?? '';
    }
  }

  @override
  void dispose() {
    _patientDebounce?.cancel();
    _doctorDebounce?.cancel();
    _clinicDebounce?.cancel();
    _patientCtrl.dispose();
    _doctorCtrl.dispose();
    _clinicCtrl.dispose();
    super.dispose();
  }

  void _onPatientChanged(String query) {
    _patientDebounce?.cancel();
    final requestId = ++_patientRequestId;
    setState(() {
      _selectedPatient = null;
      _patientResults = [];
      _selectionError = null;
    });
    final clean = query.trim();
    if (clean.isNotEmpty && clean.length < 2) {
      setState(() => _loadingPatients = false);
      return;
    }
    _patientDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _searchPatients(clean, requestId),
    );
  }

  Future<void> _searchPatients(String query, int requestId) async {
    setState(() => _loadingPatients = true);
    try {
      final result = await widget.ref
          .read(searchPatientsUsecaseProvider)
          .call(query);
      if (!mounted || requestId != _patientRequestId) return;
      setState(() {
        _patientResults = result.take(8).toList();
        _loadingPatients = false;
      });
    } catch (_) {
      if (!mounted || requestId != _patientRequestId) return;
      setState(() {
        _patientResults = [];
        _loadingPatients = false;
      });
    }
  }

  void _selectPatient(User patient) {
    _patientDebounce?.cancel();
    _patientRequestId++;
    setState(() {
      _selectedPatient = patient;
      _patientCtrl.text = patient.name;
      _patientResults = [];
      _selectionError = null;
    });
  }

  void _clearPatient() {
    _patientDebounce?.cancel();
    _patientRequestId++;
    setState(() {
      _selectedPatient = null;
      _patientCtrl.clear();
      _patientResults = [];
      _loadingPatients = false;
      _selectionError = null;
    });
  }

  void _onDoctorChanged(String query) {
    _doctorDebounce?.cancel();
    final requestId = ++_doctorRequestId;
    setState(() {
      _selectedDoctor = null;
      _doctorResults = [];
      _selectionError = null;
    });
    final clean = query.trim();
    if (clean.isNotEmpty && clean.length < 2) {
      setState(() => _loadingDoctors = false);
      return;
    }
    _doctorDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _searchDoctors(clean, requestId),
    );
  }

  Future<void> _searchDoctors(String query, int requestId) async {
    setState(() => _loadingDoctors = true);
    try {
      final result = await widget.ref.read(searchUsecaseProvider).call(query);
      if (!mounted || requestId != _doctorRequestId) return;
      setState(() {
        _doctorResults = result.doctors.take(8).toList();
        _loadingDoctors = false;
      });
    } catch (_) {
      if (!mounted || requestId != _doctorRequestId) return;
      setState(() {
        _doctorResults = [];
        _loadingDoctors = false;
      });
    }
  }

  void _selectDoctor(DoctorSearchResult doctor) {
    _doctorDebounce?.cancel();
    _doctorRequestId++;
    setState(() {
      _selectedDoctor = doctor;
      _doctorCtrl.text = doctor.name;
      _doctorResults = [];
      _selectionError = null;
    });
  }

  void _clearDoctor() {
    _doctorDebounce?.cancel();
    _doctorRequestId++;
    setState(() {
      _selectedDoctor = null;
      _doctorCtrl.clear();
      _doctorResults = [];
      _loadingDoctors = false;
      _selectionError = null;
    });
  }

  void _onClinicChanged(String query) {
    _clinicDebounce?.cancel();
    final requestId = ++_clinicRequestId;
    setState(() {
      _selectedClinic = null;
      _clinicResults = [];
      _selectionError = null;
    });
    final clean = query.trim();
    if (clean.isNotEmpty && clean.length < 2) {
      setState(() => _loadingClinics = false);
      return;
    }
    _clinicDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _searchClinics(clean, requestId),
    );
  }

  Future<void> _searchClinics(String query, int requestId) async {
    setState(() => _loadingClinics = true);
    try {
      final result = await widget.ref.read(searchUsecaseProvider).call(query);
      if (!mounted || requestId != _clinicRequestId) return;
      setState(() {
        _clinicResults = result.clinics.take(8).toList();
        _loadingClinics = false;
      });
    } catch (_) {
      if (!mounted || requestId != _clinicRequestId) return;
      setState(() {
        _clinicResults = [];
        _loadingClinics = false;
      });
    }
  }

  void _selectClinic(ClinicSearchResult clinic) {
    _clinicDebounce?.cancel();
    _clinicRequestId++;
    setState(() {
      _selectedClinic = clinic;
      _clinicCtrl.text = clinic.name;
      _clinicResults = [];
      _selectionError = null;
    });
  }

  void _clearClinic() {
    _clinicDebounce?.cancel();
    _clinicRequestId++;
    setState(() {
      _selectedClinic = null;
      _clinicCtrl.clear();
      _clinicResults = [];
      _loadingClinics = false;
      _selectionError = null;
    });
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';

  int _minutes(TimeOfDay value) => value.hour * 60 + value.minute;

  Future<void> _pickTime({required bool isStart}) async {
    final current = isStart ? _startTime : _endTime;
    final selected = await showTimePicker(
      context: context,
      initialTime:
          current ??
          (isStart
              ? const TimeOfDay(hour: 8, minute: 0)
              : const TimeOfDay(hour: 17, minute: 0)),
    );
    if (selected == null || !mounted) return;
    if (isStart &&
        _endTime != null &&
        _minutes(selected) >= _minutes(_endTime!)) {
      setState(
        () => _timeError = 'La hora inicial debe ser anterior a la final.',
      );
      return;
    }
    if (!isStart &&
        _startTime != null &&
        _minutes(selected) <= _minutes(_startTime!)) {
      setState(
        () => _timeError = 'La hora final debe ser posterior a la inicial.',
      );
      return;
    }
    setState(() {
      if (isStart) {
        _startTime = selected;
      } else {
        _endTime = selected;
      }
      _timeError = null;
    });
  }

  void _clearTime({required bool isStart}) {
    setState(() {
      if (isStart) {
        _startTime = null;
      } else {
        _endTime = null;
      }
      _timeError = null;
    });
  }

  void _apply() {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime != null &&
        _endTime != null &&
        _minutes(_endTime!) <= _minutes(_startTime!)) {
      setState(
        () => _timeError = 'La hora final debe ser posterior a la inicial.',
      );
      return;
    }
    if (_patientCtrl.text.trim().isNotEmpty && _selectedPatient == null) {
      setState(() => _selectionError = 'Selecciona un paciente de la lista.');
      return;
    }
    if (_doctorEnabled &&
        _doctorCtrl.text.trim().isNotEmpty &&
        _selectedDoctor == null) {
      setState(() => _selectionError = 'Selecciona un doctor de la lista.');
      return;
    }
    if (_clinicEnabled &&
        _clinicCtrl.text.trim().isNotEmpty &&
        _selectedClinic == null) {
      setState(() => _selectionError = 'Selecciona una clínica de la lista.');
      return;
    }

    Navigator.pop(
      context,
      StaffCalendarFilterState(
        patientId: _selectedPatient?.id,
        patientName: _selectedPatient?.name,
        doctorId: _doctorEnabled ? _selectedDoctor?.id : null,
        doctorName: _doctorEnabled ? _selectedDoctor?.name : null,
        filterDoctor: widget.allowDoctorFilter && _doctorEnabled,
        clinicId: _clinicEnabled ? _selectedClinic?.id : null,
        clinicName: _clinicEnabled ? _selectedClinic?.name : null,
        filterClinic: _clinicEnabled,
        startTime: _startTime == null ? null : _formatTime(_startTime!),
        endTime: _endTime == null ? null : _formatTime(_endTime!),
        showSchedules: _showSchedules,
        showBlockades: _showBlockades,
        showAppointments: _showAppointments,
        showCancelled: _showAppointments && _showCancelled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtrar calendario'),
      content: SizedBox(
        width: 430,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchInputField<User>(
                  controller: _patientCtrl,
                  label: 'Paciente',
                  hintText: 'Nombre del paciente',
                  compact: true,
                  loading: _loadingPatients,
                  selectedItem: _selectedPatient,
                  results: _patientResults,
                  titleBuilder: (patient) => patient.name,
                  subtitleBuilder: (patient) => patient.email,
                  onChanged: _onPatientChanged,
                  onSelected: _selectPatient,
                  onClear: _clearPatient,
                  onEmptyFocus: () {
                    final requestId = ++_patientRequestId;
                    unawaited(_searchPatients('', requestId));
                  },
                ),
                const SizedBox(height: 18),
                Text(
                  'Filtrar ítems por hora:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _TimeFilterButton(
                        label: 'Desde',
                        value: _startTime,
                        onPressed: () => _pickTime(isStart: true),
                        onClear: () => _clearTime(isStart: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimeFilterButton(
                        label: 'Hasta',
                        value: _endTime,
                        onPressed: () => _pickTime(isStart: false),
                        onClear: () => _clearTime(isStart: false),
                      ),
                    ),
                  ],
                ),
                if (_timeError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _timeError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (widget.allowDoctorFilter) ...[
                  _checkbox(
                    label: 'Filtrar por doctor',
                    value: _doctorEnabled,
                    onChanged: (value) {
                      setState(() => _doctorEnabled = value);
                      if (!value) _clearDoctor();
                    },
                  ),
                  if (_doctorEnabled) ...[
                    const SizedBox(height: 6),
                    SearchInputField<DoctorSearchResult>(
                      controller: _doctorCtrl,
                      label: 'Doctor',
                      hintText: 'Nombre o especialidad del doctor',
                      compact: true,
                      loading: _loadingDoctors,
                      selectedItem: _selectedDoctor,
                      results: _doctorResults,
                      titleBuilder: (doctor) => doctor.name,
                      subtitleBuilder: (doctor) => doctor.specialty,
                      onChanged: _onDoctorChanged,
                      onSelected: _selectDoctor,
                      onClear: _clearDoctor,
                      onEmptyFocus: () {
                        final requestId = ++_doctorRequestId;
                        unawaited(_searchDoctors('', requestId));
                      },
                    ),
                  ],
                ],
                _checkbox(
                  label: 'Filtrar por clínica',
                  value: _clinicEnabled,
                  onChanged: (value) {
                    setState(() => _clinicEnabled = value);
                    if (!value) _clearClinic();
                  },
                ),
                if (_clinicEnabled) ...[
                  const SizedBox(height: 6),
                  SearchInputField<ClinicSearchResult>(
                    controller: _clinicCtrl,
                    label: 'Clínica',
                    hintText: 'Nombre de la clínica',
                    compact: true,
                    loading: _loadingClinics,
                    selectedItem: _selectedClinic,
                    results: _clinicResults,
                    titleBuilder: (clinic) => clinic.name,
                    subtitleBuilder: (clinic) => clinic.address,
                    onChanged: _onClinicChanged,
                    onSelected: _selectClinic,
                    onClear: _clearClinic,
                    onEmptyFocus: () {
                      final requestId = ++_clinicRequestId;
                      unawaited(_searchClinics('', requestId));
                    },
                  ),
                ],
                _checkbox(
                  label: 'Mostrar horarios',
                  value: _showSchedules,
                  onChanged: (value) => setState(() => _showSchedules = value),
                ),
                _checkbox(
                  label: 'Mostrar bloqueos',
                  value: _showBlockades,
                  onChanged: (value) => setState(() => _showBlockades = value),
                ),
                _checkbox(
                  label: 'Mostrar citas',
                  value: _showAppointments,
                  onChanged: (value) =>
                      setState(() => _showAppointments = value),
                ),
                if (_showAppointments)
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: _checkbox(
                      label: 'Mostrar citas canceladas',
                      value: _showCancelled,
                      onChanged: (value) =>
                          setState(() => _showCancelled = value),
                    ),
                  ),
                if (_selectionError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _selectionError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _apply, child: const Text('Aplicar')),
      ],
    );
  }

  Widget _checkbox({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(label),
      value: value,
      onChanged: (newValue) => onChanged(newValue ?? false),
    );
  }
}

class _TimeFilterButton extends StatelessWidget {
  final String label;
  final TimeOfDay? value;
  final VoidCallback onPressed;
  final VoidCallback onClear;

  const _TimeFilterButton({
    required this.label,
    required this.value,
    required this.onPressed,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = value == null
        ? 'Sin límite'
        : '${value!.hour.toString().padLeft(2, '0')}:'
              '${value!.minute.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                  onPressed: onPressed,
                  icon: const Icon(Icons.access_time, size: 18),
                  label: Text(formatted),
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 4),
                Tooltip(
                  message: 'Limpiar $label',
                  child: InkResponse(
                    onTap: onClear,
                    radius: 13,
                    highlightShape: BoxShape.circle,
                    child: const SizedBox(
                      width: 32,
                      height: 40,
                      child: Icon(Icons.close, size: 18),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
