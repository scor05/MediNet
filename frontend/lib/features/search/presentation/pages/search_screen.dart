import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/calendar/domain/entities/public_slot.dart';
import 'package:frontend/features/calendar/presentation/dialogs/public_create_appointment_dialog.dart';
import 'package:frontend/features/calendar/presentation/pages/public_calendar_screen.dart';
import 'package:frontend/features/calendar/presentation/providers/public_calendar_provider.dart';
import 'package:frontend/features/search/presentation/providers/search_form_provider.dart';
import 'package:frontend/features/search/presentation/widgets/search_filters_panel.dart';
import 'package:frontend/features/search/presentation/widgets/search_placeholder.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';
import 'package:frontend/theme/app_theme.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _doctorCtrl = TextEditingController();

  @override
  void dispose() {
    _doctorCtrl.dispose();
    super.dispose();
  }

  void _selectDoctor(DoctorSearchResult doctor) {
    _doctorCtrl.text = doctor.name;

    ref.read(searchFormNotifierProvider.notifier).selectDoctor(doctor);
  }

  void _clearDoctor() {
    _doctorCtrl.clear();

    final notifier = ref.read(searchFormNotifierProvider.notifier);

    notifier.clearDoctor();
    notifier.showDoctorSuggestions();
  }

  void _onDoctorChanged(String query) {
    ref.read(searchFormNotifierProvider.notifier).onDoctorQueryChanged(query);
  }

  void _submitSearch() {
    FocusScope.of(context).unfocus();

    ref.read(searchFormNotifierProvider.notifier).submitSearch();
  }

  Future<void> _openCreateAppointment({int? clinicId, DateTime? date}) async {
    final filters = ref.read(publicCalendarFilterProvider);
    final search = ref.read(searchFormNotifierProvider);
    final doctorId =
        search.submittedDoctor?.id ??
        search.selectedDoctor?.id ??
        filters.doctorId;

    final selectedSlot = await showModalBottomSheet<PublicSlot>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => PublicCreateAppointmentDialog(
        initialDoctorId: doctorId,
        initialClinicId: clinicId,
        initialDate: date,
      ),
    );

    if (selectedSlot != null) {
      ref.read(publicCalendarNotifierProvider.notifier).refresh();
    }
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
            state: state,
            onDoctorChanged: _onDoctorChanged,
            onDoctorSelected: _selectDoctor,
            onDoctorCleared: _clearDoctor,
            onDoctorEmptyFocus: notifier.showDoctorSuggestions,
            onSearchPressed: _submitSearch,
            onSchedulePressed: () => _openCreateAppointment(),
          ),
          Expanded(
            child: state.hasSearched
                ? PublicCalendarScreen(
                    doctorId: state.submittedDoctor?.id,
                    doctorName: state.submittedDoctor?.name,
                    onScheduleTap: (Schedule schedule, DateTime date) {
                      _openCreateAppointment(
                        clinicId: schedule.clinicId,
                        date: date,
                      );
                    },
                  )
                : const SearchPlaceholder(),
          ),
        ],
      ),
    );
  }
}
