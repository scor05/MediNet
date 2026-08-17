import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/clinic/domain/entities/clinic_search_result.dart';
import 'package:frontend/features/search/domain/providers/search_domain_providers.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';

class SearchFormState {
  final List<DoctorSearchResult> doctorResults;
  final List<ClinicSearchResult> clinicResults;

  final DoctorSearchResult? selectedDoctor;
  final ClinicSearchResult? selectedClinic;

  final DoctorSearchResult? submittedDoctor;
  final ClinicSearchResult? submittedClinic;

  final bool loadingDoctors;
  final bool loadingClinics;
  final bool hasSearched;

  final String? error;

  const SearchFormState({
    this.doctorResults = const [],
    this.clinicResults = const [],
    this.selectedDoctor,
    this.selectedClinic,
    this.submittedDoctor,
    this.submittedClinic,
    this.loadingDoctors = false,
    this.loadingClinics = false,
    this.hasSearched = false,
    this.error,
  });

  bool get canSearch => selectedDoctor != null && selectedClinic != null;

  SearchFormState copyWith({
    List<DoctorSearchResult>? doctorResults,
    List<ClinicSearchResult>? clinicResults,
    DoctorSearchResult? selectedDoctor,
    ClinicSearchResult? selectedClinic,
    DoctorSearchResult? submittedDoctor,
    ClinicSearchResult? submittedClinic,
    bool? loadingDoctors,
    bool? loadingClinics,
    bool? hasSearched,
    String? error,
    bool clearDoctorResults = false,
    bool clearClinicResults = false,
    bool clearSelectedDoctor = false,
    bool clearSelectedClinic = false,
    bool clearSubmittedDoctor = false,
    bool clearSubmittedClinic = false,
    bool clearError = false,
  }) {
    return SearchFormState(
      doctorResults: clearDoctorResults
          ? const []
          : doctorResults ?? this.doctorResults,
      clinicResults: clearClinicResults
          ? const []
          : clinicResults ?? this.clinicResults,
      selectedDoctor: clearSelectedDoctor
          ? null
          : selectedDoctor ?? this.selectedDoctor,
      selectedClinic: clearSelectedClinic
          ? null
          : selectedClinic ?? this.selectedClinic,
      submittedDoctor: clearSubmittedDoctor
          ? null
          : submittedDoctor ?? this.submittedDoctor,
      submittedClinic: clearSubmittedClinic
          ? null
          : submittedClinic ?? this.submittedClinic,
      loadingDoctors: loadingDoctors ?? this.loadingDoctors,
      loadingClinics: loadingClinics ?? this.loadingClinics,
      hasSearched: hasSearched ?? this.hasSearched,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class SearchFormNotifier extends AutoDisposeNotifier<SearchFormState> {
  Timer? _doctorDebounce;
  Timer? _clinicDebounce;

  int _doctorRequestId = 0;
  int _clinicRequestId = 0;

  @override
  SearchFormState build() {
    ref.onDispose(() {
      _doctorDebounce?.cancel();
      _clinicDebounce?.cancel();
    });

    return const SearchFormState();
  }

  void onDoctorQueryChanged(String query) {
    _doctorDebounce?.cancel();
    _clinicDebounce?.cancel();

    final requestId = ++_doctorRequestId;
    _clinicRequestId++;

    state = state.copyWith(
      clearSelectedDoctor: true,
      clearSelectedClinic: true,
      clearDoctorResults: true,
      clearClinicResults: true,
      loadingClinics: false,
      hasSearched: false,
      clearSubmittedDoctor: true,
      clearSubmittedClinic: true,
      clearError: true,
    );

    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      unawaited(_searchDoctors('', requestId));
      return;
    }

    if (cleanQuery.length < 2) {
      state = state.copyWith(loadingDoctors: false);
      return;
    }

    _doctorDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _searchDoctors(cleanQuery, requestId),
    );
  }

  void onClinicQueryChanged(String query) {
    _clinicDebounce?.cancel();

    final requestId = ++_clinicRequestId;

    state = state.copyWith(
      clearSelectedClinic: true,
      clearClinicResults: true,
      hasSearched: false,
      clearSubmittedDoctor: true,
      clearSubmittedClinic: true,
      clearError: true,
    );

    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      unawaited(_searchClinics('', requestId));
      return;
    }

    if (cleanQuery.length < 2) {
      state = state.copyWith(loadingClinics: false);
      return;
    }

    _clinicDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _searchClinics(cleanQuery, requestId),
    );
  }

  void showDoctorSuggestions() {
    if (state.selectedDoctor != null) return;

    _doctorDebounce?.cancel();

    final requestId = ++_doctorRequestId;
    unawaited(_searchDoctors('', requestId));
  }

  void showClinicSuggestions() {
    if (state.selectedDoctor == null) return;
    if (state.selectedClinic != null) return;

    _clinicDebounce?.cancel();

    final requestId = ++_clinicRequestId;
    unawaited(_searchClinics('', requestId));
  }

  Future<void> _searchDoctors(String query, int requestId) async {
    state = state.copyWith(loadingDoctors: true, clearError: true);

    try {
      final result = await ref.read(searchUsecaseProvider).call(query);

      if (requestId != _doctorRequestId) return;

      state = state.copyWith(
        doctorResults: result.doctors.take(16).toList(),
        loadingDoctors: false,
      );
    } catch (e) {
      if (requestId != _doctorRequestId) return;

      state = state.copyWith(
        doctorResults: const [],
        loadingDoctors: false,
        error: e is ApiException ? e.message : 'Error al buscar doctores.',
      );
    }
  }

  Future<void> _searchClinics(String query, int requestId) async {
    state = state.copyWith(loadingClinics: true, clearError: true);

    try {
      final result = await ref.read(searchUsecaseProvider).call(query);

      if (requestId != _clinicRequestId) return;

      state = state.copyWith(
        clinicResults: result.clinics.take(16).toList(),
        loadingClinics: false,
      );
    } catch (e) {
      if (requestId != _clinicRequestId) return;

      state = state.copyWith(
        clinicResults: const [],
        loadingClinics: false,
        error: e is ApiException ? e.message : 'Error al buscar clínicas.',
      );
    }
  }

  void selectDoctor(DoctorSearchResult doctor) {
    _doctorDebounce?.cancel();
    _clinicDebounce?.cancel();

    _doctorRequestId++;
    _clinicRequestId++;

    state = state.copyWith(
      selectedDoctor: doctor,
      clearSelectedClinic: true,
      loadingDoctors: false,
      loadingClinics: false,
      clearDoctorResults: true,
      clearClinicResults: true,
      hasSearched: false,
      clearSubmittedDoctor: true,
      clearSubmittedClinic: true,
      clearError: true,
    );
  }

  void selectClinic(ClinicSearchResult clinic) {
    _clinicDebounce?.cancel();
    _clinicRequestId++;

    state = state.copyWith(
      selectedClinic: clinic,
      loadingClinics: false,
      clearClinicResults: true,
      hasSearched: false,
      clearSubmittedDoctor: true,
      clearSubmittedClinic: true,
      clearError: true,
    );
  }

  void clearDoctor() {
    _doctorDebounce?.cancel();
    _clinicDebounce?.cancel();

    _doctorRequestId++;
    _clinicRequestId++;

    state = state.copyWith(
      loadingDoctors: false,
      loadingClinics: false,
      clearSelectedDoctor: true,
      clearSelectedClinic: true,
      clearDoctorResults: true,
      clearClinicResults: true,
      hasSearched: false,
      clearSubmittedDoctor: true,
      clearSubmittedClinic: true,
      clearError: true,
    );
  }

  void clearClinic() {
    _clinicDebounce?.cancel();
    _clinicRequestId++;

    state = state.copyWith(
      loadingClinics: false,
      clearSelectedClinic: true,
      clearClinicResults: true,
      hasSearched: false,
      clearSubmittedDoctor: true,
      clearSubmittedClinic: true,
      clearError: true,
    );
  }

  void submitSearch() {
    if (!state.canSearch) return;

    state = state.copyWith(
      submittedDoctor: state.selectedDoctor,
      submittedClinic: state.selectedClinic,
      clearDoctorResults: true,
      clearClinicResults: true,
      hasSearched: true,
      clearError: true,
    );
  }
}

final searchFormNotifierProvider =
    AutoDisposeNotifierProvider<SearchFormNotifier, SearchFormState>(
      SearchFormNotifier.new,
    );
