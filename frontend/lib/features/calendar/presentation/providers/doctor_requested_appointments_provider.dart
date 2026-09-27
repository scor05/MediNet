import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/providers/appointment_domain_providers.dart';

class DoctorRequestedAppointmentsNotifier
    extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() => _fetch();

  Future<List<Appointment>> _fetch() async {
    final appointments = await ref.read(getDoctorAppointmentsUsecaseProvider)();

    return appointments
        .where(
          (appointment) =>
              appointment.status == 'requested' && !appointment.isBlockade,
        )
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<Appointment>>().copyWithPrevious(state);
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> updateStatus({
    required int appointmentId,
    required String status,
  }) async {
    await ref.read(updateAppointmentStatusUsecaseProvider)(
      appointmentId: appointmentId,
      status: status,
    );

    final currentAppointments = state.valueOrNull;
    if (currentAppointments == null) {
      await refresh();
      return;
    }

    state = AsyncData(
      currentAppointments
          .where((appointment) => appointment.id != appointmentId)
          .toList(),
    );
  }
}

final doctorRequestedAppointmentsNotifierProvider =
    AsyncNotifierProvider<
      DoctorRequestedAppointmentsNotifier,
      List<Appointment>
    >(DoctorRequestedAppointmentsNotifier.new);
