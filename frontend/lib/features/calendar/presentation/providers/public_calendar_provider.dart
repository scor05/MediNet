import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/calendar/domain/entities/public_slot.dart';
import 'package:frontend/features/calendar/domain/providers/public_calendar_domain_providers.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';
import 'package:frontend/features/user/domain/entities/user.dart';

class PublicCalendarState {
  final List<User> doctors;
  final List<Clinic> clinics;
  final List<PublicSlot> slots;
  final int? activeDoctorId;
  final int? activeClinicId;
  final DateTime? selectedDate;
  final bool loadingSlots;
  final String? slotsError;

  const PublicCalendarState({
    this.doctors = const [],
    this.clinics = const [],
    this.slots = const [],
    this.activeDoctorId,
    this.activeClinicId,
    this.selectedDate,
    this.loadingSlots = false,
    this.slotsError,
  });

  PublicCalendarState copyWith({
    List<User>? doctors,
    List<Clinic>? clinics,
    List<PublicSlot>? slots,
    int? activeDoctorId,
    int? activeClinicId,
    DateTime? selectedDate,
    bool? loadingSlots,
    String? slotsError,
    bool clearSlotsError = false,
    bool clearSelectedDate = false,
  }) {
    return PublicCalendarState(
      doctors: doctors ?? this.doctors,
      clinics: clinics ?? this.clinics,
      slots: slots ?? this.slots,
      activeDoctorId: activeDoctorId ?? this.activeDoctorId,
      activeClinicId: activeClinicId ?? this.activeClinicId,
      selectedDate: clearSelectedDate
          ? null
          : selectedDate ?? this.selectedDate,
      loadingSlots: loadingSlots ?? this.loadingSlots,
      slotsError: clearSlotsError ? null : slotsError ?? this.slotsError,
    );
  }
}

class PublicCalendarNotifier extends AsyncNotifier<PublicCalendarState> {
  @override
  Future<PublicCalendarState> build() async {
    final doctors = await ref.read(getPublicDoctorsUsecaseProvider).call();
    final clinics = await ref.read(getPublicClinicsUsecaseProvider).call();

    return PublicCalendarState(
      doctors: doctors,
      clinics: clinics,
      activeDoctorId: doctors.isNotEmpty ? doctors.first.id : null,
      activeClinicId: clinics.isNotEmpty ? clinics.first.id : null,
      selectedDate: DateTime.now(),
    );
  }

  // Se establece el doctor activo para filtros y modal
  void setActiveDoctorId(int? doctorId) {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        activeDoctorId: doctorId,
        slots: [],
        clearSlotsError: true,
      ),
    );
  }

  // Se establece la clínica activa para filtros y modal
  void setActiveClinicId(int? clinicId) {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        activeClinicId: clinicId,
        slots: [],
        clearSlotsError: true,
      ),
    );
  }

  // Se establece la fecha activa para consultar slots
  void setSelectedDate(DateTime date) {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(selectedDate: date, slots: [], clearSlotsError: true),
    );
  }

  // Se actualizan los valores activos desde el contexto de navegación
  void setActiveContext({int? doctorId, int? clinicId}) {
    final current = state.value;
    if (current == null) return;

    final hasDoctor = current.doctors.any((doctor) => doctor.id == doctorId);
    final hasClinic = current.clinics.any((clinic) => clinic.id == clinicId);

    state = AsyncData(
      current.copyWith(
        activeDoctorId: hasDoctor ? doctorId : current.activeDoctorId,
        activeClinicId: hasClinic ? clinicId : current.activeClinicId,
        clearSlotsError: true,
      ),
    );
  }

  // Se obtienen los slots disponibles con el doctor, clínica y fecha activos
  Future<void> getSlots() async {
    final current = state.value;
    if (current == null) return;

    final doctorId = current.activeDoctorId;
    final clinicId = current.activeClinicId;
    final date = current.selectedDate;

    if (doctorId == null || clinicId == null || date == null) {
      state = AsyncData(
        current.copyWith(
          slots: [],
          slotsError: 'Selecciona doctor, clínica y fecha.',
        ),
      );
      return;
    }

    state = AsyncData(
      current.copyWith(loadingSlots: true, clearSlotsError: true),
    );

    try {
      final slots = await ref
          .read(getPublicSlotsUsecaseProvider)
          .call(doctorId: doctorId, clinicId: clinicId, date: date);

      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(
          slots: slots,
          loadingSlots: false,
          clearSlotsError: true,
        ),
      );
    } catch (e) {
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(
          slots: [],
          loadingSlots: false,
          slotsError: e.toString(),
        ),
      );
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final publicCalendarNotifierProvider =
    AsyncNotifierProvider<PublicCalendarNotifier, PublicCalendarState>(
      PublicCalendarNotifier.new,
    );
