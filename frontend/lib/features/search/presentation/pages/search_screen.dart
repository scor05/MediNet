import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/calendar/presentation/pages/public_calendar_screen.dart';
import 'package:frontend/features/clinic/domain/entities/clinic_search_result.dart';
import 'package:frontend/features/search/presentation/providers/search_form_provider.dart';
import 'package:frontend/features/search/presentation/widgets/search_filters_panel.dart';
import 'package:frontend/features/search/presentation/widgets/search_placeholder.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';
import 'package:frontend/theme/app_theme.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _doctorCtrl = TextEditingController();
  final _clinicCtrl = TextEditingController();

  @override
  void dispose() {
    _doctorCtrl.dispose();
    _clinicCtrl.dispose();
    super.dispose();
  }

  void _selectDoctor(DoctorSearchResult doctor) {
    _doctorCtrl.text = doctor.name;
    ref.read(searchFormNotifierProvider.notifier).selectDoctor(doctor);
  }

  void _selectClinic(ClinicSearchResult clinic) {
    _clinicCtrl.text = clinic.name;
    ref.read(searchFormNotifierProvider.notifier).selectClinic(clinic);
  }

  void _clearDoctor() {
    _doctorCtrl.clear();
    ref.read(searchFormNotifierProvider.notifier).clearDoctor();
  }

  void _clearClinic() {
    _clinicCtrl.clear();
    ref.read(searchFormNotifierProvider.notifier).clearClinic();
  }

  void _submitSearch() {
    FocusScope.of(context).unfocus();
    ref.read(searchFormNotifierProvider.notifier).submitSearch();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchFormNotifierProvider);
    final notifier = ref.read(searchFormNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Buscar cita'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          SearchFiltersPanel(
            doctorController: _doctorCtrl,
            clinicController: _clinicCtrl,
            state: state,
            onDoctorChanged: notifier.onDoctorQueryChanged,
            onClinicChanged: notifier.onClinicQueryChanged,
            onDoctorSelected: _selectDoctor,
            onClinicSelected: _selectClinic,
            onDoctorCleared: _clearDoctor,
            onClinicCleared: _clearClinic,
            onSearchPressed: _submitSearch,
          ),
          Expanded(
            child: state.hasSearched
                ? PublicCalendarScreen(
                    doctorId: state.submittedDoctor?.id,
                    clinicId: state.submittedClinic?.id,
                  )
                : const SearchPlaceholder(),
          ),
        ],
      ),
    );
  }
}
