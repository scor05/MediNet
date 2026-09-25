import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/admin/data/datasources/doctor_specialty_remote_datasource.dart';
import 'package:frontend/features/admin/domain/entities/doctor_specialty.dart';
import 'package:frontend/features/admin/domain/entities/specialty.dart';

class DoctorSpecialtiesState {
  final List<Specialty> availableSpecialties;
  final List<DoctorSpecialty> assignedSpecialties;

  final bool loading;
  final bool saving;

  final String? error;

  const DoctorSpecialtiesState({
    this.availableSpecialties = const [],
    this.assignedSpecialties = const [],
    this.loading = false,
    this.saving = false,
    this.error,
  });

  DoctorSpecialtiesState copyWith({
    List<Specialty>? availableSpecialties,
    List<DoctorSpecialty>? assignedSpecialties,
    bool? loading,
    bool? saving,
    String? error,
    bool clearError = false,
  }) {
    return DoctorSpecialtiesState(
      availableSpecialties: availableSpecialties ?? this.availableSpecialties,
      assignedSpecialties: assignedSpecialties ?? this.assignedSpecialties,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final doctorSpecialtyRemoteDatasourceProvider =
    Provider<DoctorSpecialtyRemoteDatasource>((ref) {
      return DoctorSpecialtyRemoteDatasource();
    });

final doctorSpecialtiesProvider =
    AutoDisposeNotifierProviderFamily<
      DoctorSpecialtiesNotifier,
      DoctorSpecialtiesState,
      int
    >(DoctorSpecialtiesNotifier.new);

class DoctorSpecialtiesNotifier
    extends AutoDisposeFamilyNotifier<DoctorSpecialtiesState, int> {
  @override
  DoctorSpecialtiesState build(int doctorId) {
    Future.microtask(load);

    return const DoctorSpecialtiesState(loading: true);
  }

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);

    try {
      final datasource = ref.read(doctorSpecialtyRemoteDatasourceProvider);

      final results = await Future.wait([
        datasource.getSpecialties(),
        datasource.getDoctorSpecialties(arg),
      ]);

      state = state.copyWith(
        availableSpecialties: results[0] as List<Specialty>,
        assignedSpecialties: results[1] as List<DoctorSpecialty>,
        loading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e is ApiException
            ? e.message
            : 'No se pudieron cargar las especialidades.',
      );
    }
  }

  Future<bool> addSpecialty(int specialtyId) async {
    if (state.saving) return false;

    state = state.copyWith(saving: true, clearError: true);

    try {
      await ref
          .read(doctorSpecialtyRemoteDatasourceProvider)
          .addDoctorSpecialty(doctorId: arg, specialtyId: specialtyId);

      await load();

      state = state.copyWith(saving: false, clearError: true);

      return true;
    } catch (e) {
      state = state.copyWith(
        saving: false,
        error: e is ApiException
            ? e.message
            : 'No se pudo agregar la especialidad.',
      );

      return false;
    }
  }

  Future<bool> removeSpecialty(int specialtyId) async {
    if (state.saving) return false;

    state = state.copyWith(saving: true, clearError: true);

    try {
      await ref
          .read(doctorSpecialtyRemoteDatasourceProvider)
          .deleteDoctorSpecialty(doctorId: arg, specialtyId: specialtyId);

      await load();

      state = state.copyWith(saving: false, clearError: true);

      return true;
    } catch (e) {
      state = state.copyWith(
        saving: false,
        error: e is ApiException
            ? e.message
            : 'No se pudo eliminar la especialidad.',
      );

      return false;
    }
  }

  Future<Specialty?> createSpecialty(String name) async {
    if (state.saving) return null;

    state = state.copyWith(saving: true, clearError: true);

    try {
      final created = await ref
          .read(doctorSpecialtyRemoteDatasourceProvider)
          .createSpecialty(name);

      await load();

      state = state.copyWith(saving: false, clearError: true);

      return created;
    } catch (e) {
      state = state.copyWith(
        saving: false,
        error: e is ApiException
            ? e.message
            : 'No se pudo crear la especialidad.',
      );

      return null;
    }
  }
}
