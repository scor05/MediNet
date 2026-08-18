import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/waitlist/domain/entities/waitlist.dart';
import 'package:frontend/features/waitlist/domain/providers/waitlist_domain_providers.dart';
import 'package:frontend/features/waitlist/domain/repositories/waitlist_repository.dart';
import 'package:frontend/features/waitlist/domain/usecases/create_waitlist_usecase.dart';
import 'package:frontend/features/waitlist/presentation/dialogs/join_waitlist_dialog.dart';
import 'package:frontend/features/waitlist/presentation/providers/waitlist_provider.dart';

class _FakeWaitlistRepository implements WaitlistRepository {
  @override
  Future<Waitlist> createWaitlist({
    required int scheduleId,
    required DateTime date,
    required String startTime,
  }) async {
    return Waitlist(
      id: 4,
      patientId: 7,
      targetAppointmentId: 12,
      fallbackAppointmentId: null,
      status: 'waiting',
      createdAt: DateTime(2026, 8, 18),
      updatedAt: DateTime(2026, 8, 18),
    );
  }

  @override
  Future<void> cancelWaitlist({required int waitlistId}) async {}

  @override
  Future<List<Waitlist>> getPatientWaitlists() async => const [];
}

class _CountingPatientWaitlistNotifier extends PatientWaitlistNotifier {
  final VoidCallback onBuild;

  _CountingPatientWaitlistNotifier(this.onBuild);

  @override
  FutureOr<List<Waitlist>> build() {
    onBuild();
    return const [];
  }
}

void main() {
  testWidgets('refreshes the patient waitlist after a successful join', (
    tester,
  ) async {
    var waitlistBuilds = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          createWaitlistUsecaseProvider.overrideWithValue(
            CreateWaitlistUsecase(_FakeWaitlistRepository()),
          ),
          patientWaitlistNotifierProvider.overrideWith(
            () => _CountingPatientWaitlistNotifier(() => waitlistBuilds++),
          ),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              ref.watch(patientWaitlistNotifierProvider);
              return Scaffold(
                body: TextButton(
                  onPressed: () => showDialog<bool>(
                    context: context,
                    builder: (_) => JoinWaitlistDialog(
                      scheduleId: 3,
                      doctorName: 'Ana López',
                      clinicName: 'Zona 15',
                      date: DateTime(2026, 8, 20),
                      startTime: '09:30',
                    ),
                  ),
                  child: const Text('Abrir'),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(waitlistBuilds, 1);

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unirme'));
    await tester.pumpAndSettle();

    expect(waitlistBuilds, 2);
    expect(find.text('Lista de espera'), findsNothing);
  });
}
