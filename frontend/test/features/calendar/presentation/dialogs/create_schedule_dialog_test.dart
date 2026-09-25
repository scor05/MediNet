import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/calendar/presentation/dialogs/create_schedule_dialog.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';
import 'package:frontend/features/clinic/domain/providers/clinic_domain_providers.dart';
import 'package:frontend/features/clinic/domain/repositories/clinic_repository.dart';
import 'package:frontend/features/clinic/domain/usecases/get_clinics_usecase.dart';

void main() {
  testWidgets('shows the doctor search only for secretary schedule creation', (
    tester,
  ) async {
    await tester.pumpWidget(_app(forSecretary: true));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Doctor'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNull);

    await tester.pumpWidget(_app(forSecretary: false));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Doctor'), findsNothing);
    expect(_submitButton(tester).onPressed, isNotNull);
  });
}

FilledButton _submitButton(WidgetTester tester) => tester.widget<FilledButton>(
  find.widgetWithText(FilledButton, 'Guardar horario'),
);

Widget _app({required bool forSecretary}) {
  final repository = _ClinicRepository();
  return ProviderScope(
    overrides: [
      getClinicsUsecaseProvider.overrideWithValue(
        GetClinicsUsecase(repository),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(body: CreateScheduleDialog(forSecretary: forSecretary)),
    ),
  );
}

class _ClinicRepository implements ClinicRepository {
  final clinic = Clinic(
    id: 1,
    name: 'Clínica Central',
    address: 'Zona 1',
    phone: '2222-2222',
    email: 'clinica@example.com',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    isActive: true,
  );

  @override
  Future<List<Clinic>> getClinics(int? clientId) async => [clinic];

  @override
  Future<Clinic> createClinic({
    required String name,
    required String address,
    required String phone,
    required String email,
    required int clientId,
  }) async => clinic;

  @override
  Future<void> deleteClinic(int clinicId) async {}

  @override
  Future<Clinic> updateClinic({
    required int clinicId,
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async => clinic;
}
