import 'package:flutter/material.dart';
import 'package:frontend/features/clinic/domain/entities/clinic_search_result.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';
import 'package:frontend/features/search/presentation/providers/search_form_provider.dart';
import 'package:frontend/features/search/presentation/widgets/search_input_field.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.background,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          children: [
            SearchInputField<DoctorSearchResult>(
              controller: doctorController,
              label: 'Doctor',
              hintText: 'Buscar por nombre del doctor',
              loading: state.loadingDoctors,
              selectedItem: state.selectedDoctor,
              results: state.doctorResults,
              titleBuilder: (doctor) => doctor.name,
              subtitleBuilder: (doctor) => doctor.specialty,
              onChanged: onDoctorChanged,
              onSelected: onDoctorSelected,
              onClear: onDoctorCleared,
            ),
            const SizedBox(height: 12),
            SearchInputField<ClinicSearchResult>(
              controller: clinicController,
              label: 'Clínica',
              hintText: 'Buscar por nombre de la clínica',
              loading: state.loadingClinics,
              selectedItem: state.selectedClinic,
              results: state.clinicResults,
              titleBuilder: (clinic) => clinic.name,
              subtitleBuilder: (clinic) => clinic.address,
              onChanged: onClinicChanged,
              onSelected: onClinicSelected,
              onClear: onClinicCleared,
            ),
            if (state.error != null) ...[
              const SizedBox(height: 10),
              Text(
                state.error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: AppTheme.btnDark,
                onPressed: state.canSearch ? onSearchPressed : null,
                icon: const Icon(Icons.search),
                label: const Text('Buscar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
