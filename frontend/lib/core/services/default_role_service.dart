import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para persistir y recuperar el rol predeterminado del usuario.
class DefaultRoleService {
  static const _key = 'default_role';

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
}
