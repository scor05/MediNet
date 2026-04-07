import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/config/supabase_config.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;

  // ─── Login — solo usa Supabase Auth ────────────────────────────────────────
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return AuthResult.success();
    } on AuthException catch (e) {
      return AuthResult.error(_parseSupabaseError(e.message));
    } catch (e) {
      return AuthResult.error('Error inesperado. Intenta de nuevo.');
    }
  }

  // ─── Register — Supabase Auth + POST a Laravel ─────────────────────────────
  static Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // 1. Crear cuenta en Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.error(
          'No se pudo crear la cuenta. Intenta de nuevo.',
        );
      }

      // 2. Insertar en tabla users de Laravel
      final apiResponse = await http.post(
        Uri.parse('${SupabaseConfig.apiUrl}/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      if (apiResponse.statusCode == 201) {
        return AuthResult.success();
      } else {
        // Si Laravel falla, eliminar el usuario de Supabase para no dejar inconsistencia
        await _supabase.auth.signOut();
        final body = jsonDecode(apiResponse.body);
        return AuthResult.error(
          body['message'] ?? 'Error al guardar el usuario.',
        );
      }
    } on AuthException catch (e) {
      return AuthResult.error(_parseSupabaseError(e.message));
    } catch (e) {
      return AuthResult.error('Error de conexión. Verifica tu internet.');
    }
  }

  // ─── Logout ────────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  // Traduce errores de Supabase al español
  static String _parseSupabaseError(String message) {
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
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return message;
  }
}

// ─── Resultado de operaciones de auth ─────────────────────────────────────────
class AuthResult {
  final bool success;
  final String? error;

  AuthResult._({required this.success, this.error});

  factory AuthResult.success() => AuthResult._(success: true);
  factory AuthResult.error(String message) =>
      AuthResult._(success: false, error: message);
}
