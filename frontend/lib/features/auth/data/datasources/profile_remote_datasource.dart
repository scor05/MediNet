import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception_handler.dart';

class ProfileRemoteDatasource {
  final _supabase = Supabase.instance.client;

  // Obtiene el perfil del usuario autenticado desde el backend
  // usando el access token actual de SupabaseAuth.
  Future<Map<String, dynamic>> getProfile() async {
    // Obtiene la sesión actual de Supabase
    final session = _supabase.auth.currentSession;

    // Si no existe sesión activa, no se puede continuar
    if (session == null) {
      throw Exception('No hay sesión activa.');
    }

    // Llama al endpoint protegido del backend
    final apiResponse = await http
        .get(
          Uri.parse('${AppConfig.apiUrl}/users/profile'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${session.accessToken}',
          },
        )
        .timeout(const Duration(seconds: 10));

    // Si la respuesta es exitosa, retorna el perfil decodificado
    if (apiResponse.statusCode == 200) {
      return jsonDecode(apiResponse.body) as Map<String, dynamic>;
    } else {
      throw handleApiError(apiResponse);
    }
  }
}
