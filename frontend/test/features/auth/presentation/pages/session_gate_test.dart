import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/presentation/pages/session_gate.dart';
import 'package:frontend/features/auth/presentation/providers/session_restoration_provider.dart';

void main() {
  testWidgets('shows a loader while the stored session is restored', (
    tester,
  ) async {
    final completer = Completer<Widget>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          restoredSessionHomeProvider.overrideWith((ref) => completer.future),
        ],
        child: const MaterialApp(home: SessionGate()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const Scaffold(body: Text('Calendario restaurado')));
    await tester.pumpAndSettle();

    expect(find.text('Calendario restaurado'), findsOneWidget);
  });

  testWidgets('offers retry without discarding a failed stored session', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          restoredSessionHomeProvider.overrideWith(
            (ref) => throw Exception('network unavailable'),
          ),
        ],
        child: const MaterialApp(home: SessionGate()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No se pudo restaurar tu sesión.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Cerrar sesión y volver al inicio'), findsOneWidget);
  });
}
