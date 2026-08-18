import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin/presentation/dialogs/add_clinic_dialog.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';

void main() {
  testWidgets('submits the clinic form and closes the dialog', (tester) async {
    String? submittedName;
    String? submittedAddress;
    String? submittedPhone;
    String? submittedEmail;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => AddClinicDialog(
                  onCreate:
                      ({
                        required name,
                        required address,
                        required phone,
                        required email,
                      }) async {
                        submittedName = name;
                        submittedAddress = address;
                        submittedPhone = phone;
                        submittedEmail = email;

                        return Clinic(
                          id: 9,
                          name: name,
                          address: address,
                          phone: phone,
                          email: email,
                          createdAt: DateTime(2026, 8, 17),
                          updatedAt: DateTime(2026, 8, 17),
                          isActive: true,
                        );
                      },
                ),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Clínica Central');
    await tester.enterText(fields.at(1), 'Zona 15');
    await tester.enterText(fields.at(2), '2222-3333');
    await tester.enterText(fields.at(3), 'central@medinet.lat');
    await tester.tap(find.text('Crear'));
    await tester.pumpAndSettle();

    expect(submittedName, 'Clínica Central');
    expect(submittedAddress, 'Zona 15');
    expect(submittedPhone, '2222-3333');
    expect(submittedEmail, 'central@medinet.lat');
    expect(find.text('Agregar clínica'), findsNothing);
  });
}
