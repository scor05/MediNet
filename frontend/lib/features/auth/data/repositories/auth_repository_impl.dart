import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../domain/results/auth_result.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'dart:io';
import 'dart:async';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  // Login (Solo usa SupabaseAuth)
  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      await _datasource.login(email: email, password: password);
      return AuthResult.success();
    } on AuthException catch (e) {
      return AuthResult.error(_parseSupabaseError(e.message));
    } on SocketException {
      return AuthResult.error('Sin conexión. Verifica tu internet.');
    } on TimeoutException {
      return AuthResult.error(
        'La solicitud tardó demasiado. Intenta de nuevo.',
      );
    } catch (e) {
      return AuthResult.error('Error inesperado. Intenta de nuevo.');
    }
  }

  // Signup (Solo llama al backend, quien se encarga de crear el usuario en SupabaseAuth y en la tabla users)
  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      await _datasource.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      return AuthResult.success();
    } on AuthException catch (e) {
      return AuthResult.error(_parseSupabaseError(e.message));
    } on ApiException catch (e) {
      return AuthResult.error(e.message);
    } on SocketException {
      return AuthResult.error('Sin conexión. Verifica tu internet.');
    } on TimeoutException {
      return AuthResult.error(
        'La solicitud tardó demasiado. Intenta de nuevo.',
      );
    } catch (e) {
      return AuthResult.error('Error inesperado. Intenta de nuevo.');
    }
  }

  // Logout (Solo usa SupabaseAuth)
  @override
  Future<void> logout() async {
    await _datasource.logout();
  }

  @override
  Future<UserProfile> getProfile() async {
    try {
      return await _datasource.getProfile();
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sin conexión. Verifica tu internet.');
    } on TimeoutException {
      throw ApiException('La solicitud tardó demasiado. Intenta de nuevo.');
    } catch (e) {
      throw ApiException('Error inesperado al cargar el perfil.');
    }
  }

  // Traduce errores de Supabase al español
  String _parseSupabaseError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Debes confirmar tu correo antes de iniciar sesión.';
    }
    if (message.contains('User already registered')) {
      return 'Este correo ya está registrado.';
    }
    if (message.contains('Password should be at least')) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }
    return message;
  }
}
