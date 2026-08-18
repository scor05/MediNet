import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin/presentation/widgets/client_detail/clinic_tile.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';

void main() {
  testWidgets('shows location, edit, and delete actions', (tester) async {
    var editPressed = false;
    var deletePressed = false;
    final clinic = Clinic(
      id: 1,
      name: 'Clínica Central',
      address: 'Zona 15',
      phone: '2222-3333',
      email: 'central@medinet.lat',
      createdAt: DateTime(2026, 8, 18),
      updatedAt: DateTime(2026, 8, 18),
      isActive: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClinicTile(
            clinic: clinic,
            onEdit: () => editPressed = true,
            onDelete: () => deletePressed = true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    expect(find.byIcon(Icons.local_hospital_outlined), findsNothing);

    await tester.tap(find.byTooltip('Editar clínica'));
    await tester.tap(find.byTooltip('Eliminar clínica'));

    expect(editPressed, isTrue);
    expect(deletePressed, isTrue);
  });
}
