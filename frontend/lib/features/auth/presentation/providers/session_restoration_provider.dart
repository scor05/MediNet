import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/auth/presentation/navigation/auth_navigation.dart';
import 'package:frontend/features/auth/presentation/pages/welcome_screen.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final restoredSessionHomeProvider = FutureProvider<Widget>((ref) async {
  final auth = Supabase.instance.client.auth;
  var session = auth.currentSession;

  if (session == null) {
    return const WelcomeScreen();
  }

  if (session.isExpired) {
    session = (await auth.refreshSession()).session;
    if (session == null) {
      throw const SessionRestorationException(
        'No se pudo renovar la sesión guardada.',
      );
    }
  }

  try {
    final profile = await ref.read(getProfileUsecaseProvider)();
    return AuthNavigation.screenAfterLogin(profile);
  } on ApiException catch (error) {
    if (!error.isUnauthorized) rethrow;

    session = (await auth.refreshSession()).session;
    if (session == null) {
      throw const SessionRestorationException(
        'No se pudo renovar la sesión guardada.',
      );
    }

    final profile = await ref.read(getProfileUsecaseProvider)();
    return AuthNavigation.screenAfterLogin(profile);
  }
});

class SessionRestorationException implements Exception {
  final String message;

  const SessionRestorationException(this.message);

  @override
  String toString() => message;
}
