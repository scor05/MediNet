import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/providers/appointment_domain_providers.dart';

class SecretaryPendingAppointmentsNotifier
    extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() {
    return _fetch();
  }

  Future<List<Appointment>> _fetch() {
    return ref.read(getSecretaryPendingAppointmentsUsecaseProvider)();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final secretaryPendingAppointmentsNotifierProvider =
    AsyncNotifierProvider<
      SecretaryPendingAppointmentsNotifier,
      List<Appointment>
    >(SecretaryPendingAppointmentsNotifier.new);
