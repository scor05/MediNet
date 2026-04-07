import 'dart:convert';
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

  // ─── Register — delega todo a Laravel /auth/register ──────────────────────
  static Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Laravel crea el usuario en Supabase Auth y en la BD local
      final apiResponse = await http.post(
        Uri.parse('${SupabaseConfig.apiUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      if (apiResponse.statusCode == 201) {
        // Iniciar sesión en el cliente Flutter con las mismas credenciales
        await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        return AuthResult.success();
      } else {
        final body = jsonDecode(apiResponse.body);
        // Laravel devuelve 'message' o 'error'
        final msg =
            body['message'] ?? body['error'] ?? 'Error al guardar el usuario.';
        return AuthResult.error(msg);
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
      return 'La contraseña debe tener al menos 8 caracteres.';
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
