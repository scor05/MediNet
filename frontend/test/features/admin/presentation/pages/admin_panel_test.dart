import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin/presentation/pages/admin_panel.dart';
import 'package:frontend/features/admin/presentation/providers/client_users_provider.dart';
import 'package:frontend/features/auth/domain/entities/admin_of.dart';
import 'package:frontend/features/auth/domain/entities/user_profile.dart';
import 'package:frontend/features/client/domain/entities/client_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeClientUsersNotifier extends ClientUsersNotifier {
  @override
  Future<List<ClientUser>> build(int clientId) async => [];
}

void main() {
  testWidgets('administrator opens and closes shared settings from app bar', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'test-anon-key',
    );

    const profile = UserProfile(
      id: 9,
      name: 'Administrador',
      email: 'admin@medinet.lat',
      phone: '5555-9999',
      isActive: true,
      isDoctor: true,
      isSecretary: false,
      isSuperadmin: false,
      adminOf: [AdminOf(clientId: 4, clientName: 'Clínica Central')],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientUsersNotifierProvider.overrideWith(
            _FakeClientUsersNotifier.new,
          ),
        ],
        child: const MaterialApp(
          home: AdminPanel(
            clientId: 4,
            clientName: 'Clínica Central',
            profile: profile,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mi Organización'), findsOneWidget);
    expect(find.byTooltip('Ajustes'), findsOneWidget);
    final settingsPadding = tester.widget<Padding>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Padding &&
            widget.child is IconButton &&
            (widget.child! as IconButton).tooltip == 'Ajustes',
      ),
    );
    expect(settingsPadding.padding, const EdgeInsets.only(right: 4));

    await tester.tap(find.byTooltip('Ajustes'));
    await tester.pumpAndSettle();

    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Cambiar de rol'), findsWidgets);
    expect(find.byTooltip('Volver'), findsOneWidget);

    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();

    expect(find.text('Mi Organización'), findsOneWidget);
    Supabase.instance.client.auth.stopAutoRefresh();
  });
}
