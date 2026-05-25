import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception_handler.dart';

class NotificationPreferenceRemoteDatasource {
  final _supabase = Supabase.instance.client;

  Future<List<String>> getPreferences(int userId) async {
    final session = _supabase.auth.currentSession;

    if (session == null) {
      throw Exception('No hay sesión activa.');
    }

    final response = await http
        .get(
          Uri.parse('${AppConfig.apiUrl}/notification-preferences/$userId'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${session.accessToken}',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data.map((item) => item['channel'].toString()).toList();
      }

      if (data['channels'] is List) {
        return List<String>.from(data['channels']);
      }
    }

    throw handleApiError(response);
  }

  Future<void> updatePreferences({
    required int userId,
    required List<String> channels,
  }) async {
    final session = _supabase.auth.currentSession;

    if (session == null) {
      throw Exception('No hay sesión activa.');
    }

    final response = await http
        .put(
          Uri.parse('${AppConfig.apiUrl}/notification-preferences/$userId'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${session.accessToken}',
          },
          body: jsonEncode({'channels': channels}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw handleApiError(response);
    }
  }
}
