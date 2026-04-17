import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception_handler.dart';
import 'package:frontend/features/auth/data/models/user_profile_model.dart';

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
    final apiResponse = await http
        .post(
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
        )
        .timeout(const Duration(seconds: 10));

    if (apiResponse.statusCode == 201) {
      final session = jsonDecode(apiResponse.body);
      await _supabase.auth.setSession(session['refresh_token']);
    } else {
      throw handleApiError(apiResponse);
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<UserProfileModel> getProfile() async {
    final token = _supabase.auth.currentSession?.accessToken;

    final response = await http
        .get(
          Uri.parse('${AppConfig.apiUrl}/users/profile'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return UserProfileModel.fromJson(jsonDecode(response.body));
    } else {
      throw handleApiError(response);
    }
  }
}
