import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/domain/entities/user_profile.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:frontend/core/exceptions/api_exception.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(AuthRemoteDatasource());
});

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(ref.watch(authRepositoryProvider));
});

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  return RegisterUsecase(ref.watch(authRepositoryProvider));
});

final getProfileUsecaseProvider = Provider<GetProfileUsecase>((ref) {
  return GetProfileUsecase(ref.watch(authRepositoryProvider));
});

// Representa los posibles estados del flujo de autenticación
sealed class AuthState {}

// Estado inicial / pantallas de login y registro
class AuthIdle extends AuthState {}

// Cargando (login, register o getProfile en curso)
class AuthLoading extends AuthState {}

// Login o register exitoso y perfil cargado: listo para navegar
class AuthAuthenticated extends AuthState {
  final UserProfile profile;
  AuthAuthenticated(this.profile);
}

// Error en cualquier paso del flujo
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// Provee los estados del flujo de autenticación
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthIdle();

  // Ejecuta login y luego carga el perfil en un solo flujo
  Future<void> login({required String email, required String password}) async {
    state = AuthLoading();

    final result = await ref.read(loginUsecaseProvider)(
      email: email,
      password: password,
    );

    if (!result.success) {
      state = AuthError(result.error ?? 'Error inesperado.');
      return;
    }

    await _loadProfile();
  }

  // Ejecuta registro y luego carga el perfil en un solo flujo
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = AuthLoading();

    final result = await ref.read(registerUsecaseProvider)(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    if (!result.success) {
      state = AuthError(result.error ?? 'Error inesperado.');
      return;
    }

    await _loadProfile();
  }

  // Carga el perfil del usuario autenticado
  Future<void> _loadProfile() async {
    try {
      final profile = await ref.read(getProfileUsecaseProvider)();
      state = AuthAuthenticated(profile);
    } on ApiException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError(
        'Inicio de sesión exitoso, pero no se pudo cargar el perfil.',
      );
    }
  }

  // Resetea el estado
  void reset() => state = AuthIdle();
}

// Provider para el notifier
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
