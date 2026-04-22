import 'dart:convert';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception_handler.dart';
import 'package:frontend/features/user/data/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRemoteDatasource {
  // Se obtienen todos los usuarios que no son superadmins
  Future<List<UserModel>> getAvailableUsers(String search) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .get(
          Uri.parse(
            '${AppConfig.apiUrl}/users/available?search=${Uri.encodeComponent(search)}',
          ),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => UserModel.fromSearch(e)).toList();
    } else {
      throw handleApiError(response);
    }
  }
}
