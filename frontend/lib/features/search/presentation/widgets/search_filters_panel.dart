import 'package:flutter/material.dart';
import 'package:frontend/features/clinic/domain/entities/clinic_search_result.dart';
import 'package:frontend/features/search/presentation/providers/search_form_provider.dart';
import 'package:frontend/features/search/presentation/widgets/search_input_field.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';
import 'package:frontend/theme/app_theme.dart';

class SearchFiltersPanel extends StatelessWidget {
  final TextEditingController doctorController;
  final TextEditingController clinicController;
  final SearchFormState state;

  final ValueChanged<String> onDoctorChanged;
  final ValueChanged<String> onClinicChanged;
  final ValueChanged<DoctorSearchResult> onDoctorSelected;
  final ValueChanged<ClinicSearchResult> onClinicSelected;
  final VoidCallback onDoctorCleared;
  final VoidCallback onClinicCleared;
  final VoidCallback onSearchPressed;
  final VoidCallback onSchedulePressed;

  const SearchFiltersPanel({
    super.key,
    required this.doctorController,
    required this.clinicController,
    required this.state,
    required this.onDoctorChanged,
    required this.onClinicChanged,
    required this.onDoctorSelected,
    required this.onClinicSelected,
    required this.onDoctorCleared,
    required this.onClinicCleared,
    required this.onSearchPressed,
    required this.onSchedulePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.background,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SearchInputField<DoctorSearchResult>(
                    compact: true,
                    controller: doctorController,
                    label: 'Doctor',
                    hintText: 'Nombre del doctor',
                    loading: state.loadingDoctors,
                    selectedItem: state.selectedDoctor,
                    results: state.doctorResults,
                    titleBuilder: (doctor) => doctor.name,
                    subtitleBuilder: (doctor) => doctor.specialty,
                    onChanged: onDoctorChanged,
                    onSelected: onDoctorSelected,
                    onClear: onDoctorCleared,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SearchInputField<ClinicSearchResult>(
                    compact: true,
                    controller: clinicController,
                    label: 'Clínica',
                    hintText: 'Nombre de la clínica',
                    loading: state.loadingClinics,
                    selectedItem: state.selectedClinic,
                    results: state.clinicResults,
                    titleBuilder: (clinic) => clinic.name,
                    subtitleBuilder: (clinic) => clinic.address,
                    onChanged: onClinicChanged,
                    onSelected: onClinicSelected,
                    onClear: onClinicCleared,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox.square(
                  dimension: 44,
                  child: ElevatedButton(
                    style: AppTheme.btnDark.copyWith(
                      minimumSize: const WidgetStatePropertyAll(Size.zero),
                      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                    ),
                    onPressed: state.canSearch ? onSearchPressed : null,
                    child: const Icon(Icons.search, size: 18),
                  ),
                ),
              ],
            ),
            if (state.hasSearched) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onSchedulePressed,
                  icon: const Icon(Icons.event_available, size: 22),
                  label: const Text('Agendar cita'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
            if (state.error != null) ...[
              const SizedBox(height: 6),
              Text(
                state.error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
