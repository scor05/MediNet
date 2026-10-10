import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/calendar/presentation/providers/patient_calendar_filter_provider.dart';
import 'package:frontend/features/clinic/domain/entities/clinic_search_result.dart';
import 'package:frontend/features/search/domain/providers/search_domain_providers.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';

/// Shows a filter popup for the patient calendar.
/// Returns the applied [PatientCalendarFilterState] or null if cancelled.
Future<PatientCalendarFilterState?> showPatientCalendarFilterDialog({
  required BuildContext context,
  required WidgetRef ref,
  required PatientCalendarFilterState currentFilters,
}) {
  return showDialog<PatientCalendarFilterState>(
    context: context,
    builder: (_) =>
        _PatientCalendarFilterDialog(ref: ref, initialFilters: currentFilters),
  );
}

class _PatientCalendarFilterDialog extends StatefulWidget {
  final WidgetRef ref;
  final PatientCalendarFilterState initialFilters;

  const _PatientCalendarFilterDialog({
    required this.ref,
    required this.initialFilters,
  });

  @override
  State<_PatientCalendarFilterDialog> createState() =>
      _PatientCalendarFilterDialogState();
}

class _PatientCalendarFilterDialogState
    extends State<_PatientCalendarFilterDialog> {
  // Doctor filter
  bool _doctorEnabled = false;
  final _doctorCtrl = TextEditingController();
  DoctorSearchResult? _selectedDoctor;
  List<DoctorSearchResult> _doctorResults = [];
  bool _loadingDoctors = false;
  Timer? _doctorDebounce;
  int _doctorRequestId = 0;

  // Clinic filter
  bool _clinicEnabled = false;
  final _clinicCtrl = TextEditingController();
  ClinicSearchResult? _selectedClinic;
  List<ClinicSearchResult> _clinicResults = [];
  bool _loadingClinics = false;
  Timer? _clinicDebounce;
  int _clinicRequestId = 0;
  bool _showCancelled = true;

  @override
  void initState() {
    super.initState();

    final filters = widget.initialFilters;
    _showCancelled = filters.showCancelled;

    if (filters.doctorId != null) {
      _doctorEnabled = true;
      _selectedDoctor = DoctorSearchResult(
        id: filters.doctorId!,
        name: filters.doctorName ?? '',
        specialty: '',
      );
      _doctorCtrl.text = filters.doctorName ?? '';
    }

    if (filters.clinicId != null) {
      _clinicEnabled = true;
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
    _doctorDebounce?.cancel();
    _clinicDebounce?.cancel();
    _doctorCtrl.dispose();
    _clinicCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // DOCTOR SEARCH
  // ---------------------------------------------------------------------------

  void _onDoctorQueryChanged(String query) {
    _doctorDebounce?.cancel();

    final requestId = ++_doctorRequestId;

    setState(() {
      _selectedDoctor = null;
      _doctorResults = [];
    });

    final clean = query.trim();

    if (clean.length < 2) {
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

      if (requestId != _doctorRequestId || !mounted) return;

      setState(() {
        _doctorResults = result.doctors.take(8).toList();
        _loadingDoctors = false;
      });
    } catch (e) {
      if (requestId != _doctorRequestId || !mounted) return;

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
    });
  }

  // ---------------------------------------------------------------------------
  // CLINIC SEARCH
  // ---------------------------------------------------------------------------

  void _onClinicQueryChanged(String query) {
    _clinicDebounce?.cancel();

    final requestId = ++_clinicRequestId;

    setState(() {
      _selectedClinic = null;
      _clinicResults = [];
    });

    final clean = query.trim();

    if (clean.length < 2) {
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

      if (requestId != _clinicRequestId || !mounted) return;

      setState(() {
        _clinicResults = result.clinics.take(8).toList();
        _loadingClinics = false;
      });
    } catch (e) {
      if (requestId != _clinicRequestId || !mounted) return;

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
    });
  }

  // ---------------------------------------------------------------------------
  // APPLY
  // ---------------------------------------------------------------------------

  void _apply() {
    final result = PatientCalendarFilterState(
      doctorId: _doctorEnabled ? _selectedDoctor?.id : null,
      doctorName: _doctorEnabled ? _selectedDoctor?.name : null,
      clinicId: _clinicEnabled ? _selectedClinic?.id : null,
      clinicName: _clinicEnabled ? _selectedClinic?.name : null,
      showCancelled: _showCancelled,
    );

    Navigator.pop(context, result);
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtrar por:'),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- DOCTOR FILTER ----
              _FilterSection(
                label: 'Doctor',
                enabled: _doctorEnabled,
                onEnabledChanged: (value) {
                  setState(() {
                    _doctorEnabled = value;
                    if (!value) _clearDoctor();
                  });
                },
                controller: _doctorCtrl,
                hintText: 'Nombre o especialidad del doctor',
                loading: _loadingDoctors,
                selectedItem: _selectedDoctor,
                onChanged: _onDoctorQueryChanged,
                onClear: _clearDoctor,
                results: _doctorResults,
                titleBuilder: (d) => d.name,
                subtitleBuilder: (d) => d.specialty,
                onSelected: _selectDoctor,
              ),

              const SizedBox(height: 16),

              // ---- CLINIC FILTER ----
              _FilterSection(
                label: 'Clínica',
                enabled: _clinicEnabled,
                onEnabledChanged: (value) {
                  setState(() {
                    _clinicEnabled = value;
                    if (!value) _clearClinic();
                  });
                },
                controller: _clinicCtrl,
                hintText: 'Nombre de la clínica',
                loading: _loadingClinics,
                selectedItem: _selectedClinic,
                onChanged: _onClinicQueryChanged,
                onClear: _clearClinic,
                results: _clinicResults,
                titleBuilder: (c) => c.name,
                subtitleBuilder: (c) => c.address,
                onSelected: _selectClinic,
              ),

              const SizedBox(height: 12),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Mostrar citas canceladas'),
                value: _showCancelled,
                onChanged: (value) =>
                    setState(() => _showCancelled = value ?? false),
              ),
            ],
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
}

// ---------------------------------------------------------------------------
// Generic filter section widget (checkbox + search field + results)
// ---------------------------------------------------------------------------

class _FilterSection<T> extends StatelessWidget {
  final String label;
  final bool enabled;
  final ValueChanged<bool> onEnabledChanged;
  final TextEditingController controller;
  final String hintText;
  final bool loading;
  final T? selectedItem;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final List<T> results;
  final String Function(T) titleBuilder;
  final String Function(T) subtitleBuilder;
  final ValueChanged<T> onSelected;

  const _FilterSection({
    required this.label,
    required this.enabled,
    required this.onEnabledChanged,
    required this.controller,
    required this.hintText,
    required this.loading,
    required this.selectedItem,
    required this.onChanged,
    required this.onClear,
    required this.results,
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: enabled,
                onChanged: (v) => onEnabledChanged(v ?? false),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),

        if (enabled) ...[
          const SizedBox(height: 8),

          TextField(
            controller: controller,
            enabled: enabled,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              suffixIcon: loading
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : selectedItem != null
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      iconSize: 18,
                      onPressed: onClear,
                    )
                  : null,
            ),
          ),

          if (results.isNotEmpty && selectedItem == null)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: results.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                itemBuilder: (_, index) {
                  final item = results[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      titleBuilder(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                    subtitle: Text(
                      subtitleBuilder(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () => onSelected(item),
                  );
                },
              ),
            ),
        ],
      ],
    );
  }
}
