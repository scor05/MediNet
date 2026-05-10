import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/providers/appointment_domain_providers.dart';

class SecretaryRequestedAppointmentsNotifier
    extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() {
    return _fetch();
  }

  Future<List<Appointment>> _fetch() {
    return ref.read(getSecretaryRequestedAppointmentsUsecaseProvider)();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
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

    await refresh();
  }
}

final secretaryRequestedAppointmentsNotifierProvider =
    AsyncNotifierProvider<
      SecretaryRequestedAppointmentsNotifier,
      List<Appointment>
    >(SecretaryRequestedAppointmentsNotifier.new);
