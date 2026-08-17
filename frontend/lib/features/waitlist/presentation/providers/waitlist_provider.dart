import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/waitlist/domain/entities/waitlist.dart';
import 'package:frontend/features/waitlist/domain/providers/waitlist_domain_providers.dart';

/*
-------------------------------------- Notifier -----------------------------------------
*/

class PatientWaitlistNotifier extends AutoDisposeAsyncNotifier<List<Waitlist>> {
  @override
  FutureOr<List<Waitlist>> build() {
    return ref.read(getPatientWaitlistsUsecaseProvider).call();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(getPatientWaitlistsUsecaseProvider).call(),
    );
  }

  Future<void> cancelWaitlist(int waitlistId) async {
    await ref.read(cancelWaitlistUsecaseProvider).call(waitlistId: waitlistId);
    await refresh();
  }
}

/*
-------------------------------------- Providers -----------------------------------------
*/

// Provider del notifier de waitlists del paciente
final patientWaitlistNotifierProvider =
    AutoDisposeAsyncNotifierProvider<PatientWaitlistNotifier, List<Waitlist>>(
      PatientWaitlistNotifier.new,
    );
