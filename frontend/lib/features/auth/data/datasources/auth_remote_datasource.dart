import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception_handler.dart';

class AuthRemoteDatasource {
  final _supabase = Supabase.instance.client;

  Future<void> login({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final apiResponse = await http.post(
      Uri.parse('${AppConfig.apiUrl}/auth/register'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );

    if (apiResponse.statusCode == 201) {
      final session = jsonDecode(apiResponse.body);
      await _supabase.auth.setSession(session['refresh_token']);
    } else {
      handleApiError(apiResponse);
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
