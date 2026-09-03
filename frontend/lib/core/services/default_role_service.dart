import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para persistir y recuperar el rol predeterminado del usuario.
class DefaultRoleService {
  static const _key = 'default_role';
  static const _lastRoleKey = 'last_role';

  /// Devuelve el rol guardado, o `null` si no hay ninguno.
  static Future<String?> getDefaultRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  /// Guarda el rol predeterminado. Pasa `null` para borrar la preferencia.
  static Future<void> setDefaultRole(String? role) async {
    final prefs = await SharedPreferences.getInstance();
    if (role == null || role.isEmpty) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, role);
    }
  }

  /// Elimina el rol predeterminado (lo resetea a "Ninguno").
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Devuelve el último rol que el usuario seleccionó manualmente, o `null`
  /// si nunca ha iniciado sesión con un rol específico.
  static Future<String?> getLastRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastRoleKey);
  }

  /// Guarda el último rol usado. Se llama automáticamente al navegar a un rol.
  static Future<void> setLastRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastRoleKey, role);
  }

  /// Elimina el último rol recordado (p.ej. al cerrar sesión).
  static Future<void> clearLastRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastRoleKey);
  }
}
