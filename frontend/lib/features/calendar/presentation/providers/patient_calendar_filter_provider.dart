import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientCalendarFilterState {
  final int? doctorId;
  final String? doctorName;
  final int? clinicId;
  final String? clinicName;

  const PatientCalendarFilterState({
    this.doctorId,
    this.doctorName,
    this.clinicId,
    this.clinicName,
  });

  bool get hasFilters => doctorId != null || clinicId != null;

  PatientCalendarFilterState copyWith({
    int? doctorId,
    String? doctorName,
    int? clinicId,
    String? clinicName,
    bool clearDoctor = false,
    bool clearClinic = false,
  }) {
    return PatientCalendarFilterState(
      doctorId: clearDoctor ? null : doctorId ?? this.doctorId,
      doctorName: clearDoctor ? null : doctorName ?? this.doctorName,
      clinicId: clearClinic ? null : clinicId ?? this.clinicId,
      clinicName: clearClinic ? null : clinicName ?? this.clinicName,
    );
  }
}

class PatientCalendarFilterNotifier
    extends Notifier<PatientCalendarFilterState> {
  @override
  PatientCalendarFilterState build() {
    return const PatientCalendarFilterState();
  }

  void setDoctor(int id, String name) {
    state = state.copyWith(doctorId: id, doctorName: name);
  }

  void clearDoctor() {
    state = state.copyWith(clearDoctor: true);
  }

  void setClinic(int id, String name) {
    state = state.copyWith(clinicId: id, clinicName: name);
  }

  void clearClinic() {
    state = state.copyWith(clearClinic: true);
  }

  void clearAll() {
    state = const PatientCalendarFilterState();
  }
}

final patientCalendarFilterProvider =
    NotifierProvider<PatientCalendarFilterNotifier, PatientCalendarFilterState>(
      PatientCalendarFilterNotifier.new,
    );
