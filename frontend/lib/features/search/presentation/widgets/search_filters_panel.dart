import 'package:flutter/material.dart';
import 'package:frontend/features/search/presentation/providers/search_form_provider.dart';
import 'package:frontend/features/search/presentation/widgets/search_input_field.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';
import 'package:frontend/theme/app_theme.dart';

class SearchFiltersPanel extends StatelessWidget {
  final TextEditingController doctorController;
  final SearchFormState state;

  final ValueChanged<String> onDoctorChanged;
  final ValueChanged<DoctorSearchResult> onDoctorSelected;
  final VoidCallback onDoctorCleared;
  final VoidCallback onDoctorEmptyFocus;
  final VoidCallback onSearchPressed;
  final VoidCallback onSchedulePressed;

  const SearchFiltersPanel({
    super.key,
    required this.doctorController,
    required this.state,
    required this.onDoctorChanged,
    required this.onDoctorSelected,
    required this.onDoctorCleared,
    required this.onDoctorEmptyFocus,
    required this.onSearchPressed,
    required this.onSchedulePressed,
  });

  @override
  Widget build(BuildContext context) {
    final doctorField = SearchInputField<DoctorSearchResult>(
      compact: true,
      controller: doctorController,
      label: 'Doctor (o especialidad)',
      hintText: 'Nombre del doctor o su especialidad',
      loading: state.loadingDoctors,
      selectedItem: state.selectedDoctor,
      results: state.doctorResults,
      titleBuilder: (doctor) => doctor.name,
      subtitleBuilder: (doctor) => doctor.specialty,
      onChanged: onDoctorChanged,
      onSelected: onDoctorSelected,
      onClear: onDoctorCleared,
      onEmptyFocus: onDoctorEmptyFocus,
    );
    return Material(
      color: AppTheme.background,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 600;
                final searchButton = isNarrow
                    ? ElevatedButton.icon(
                        style: AppTheme.btnDark,
                        onPressed: state.canSearch ? onSearchPressed : null,
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text('Buscar'),
                      )
                    : ElevatedButton(
                        style: AppTheme.btnDark.copyWith(
                          minimumSize: const WidgetStatePropertyAll(Size.zero),
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.zero,
                          ),
                        ),
                        onPressed: state.canSearch ? onSearchPressed : null,
                        child: const Icon(Icons.search, size: 18),
                      );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      doctorField,
                      const SizedBox(height: 10),
                      SizedBox(height: 44, child: searchButton),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: doctorField),
                    const SizedBox(width: 10),
                    SizedBox(width: 44, height: 44, child: searchButton),
                  ],
                );
              },
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
